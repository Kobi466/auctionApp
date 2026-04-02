package com.application.auction.service;

import com.application.auction.dto.request.IntrospectRequest;
import com.application.auction.dto.request.LoginRequest;
import com.application.auction.dto.request.LogoutRequest;
import com.application.auction.dto.request.RefreshTokenRequest;
import com.application.auction.dto.response.IntrospectResponse;
import com.application.auction.dto.response.LoginResponse;
import com.application.auction.entity.RefreshToken;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.RefreshTokenRepository;
import com.application.auction.repository.UserRepository;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.StringJoiner;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class LoginService {

    UserRepository userRepository;
    RefreshTokenRepository refreshTokenRepository;
    ProfileService profileService;



    static final String ACCESS_TOKEN_TYPE = "access";
    static final String REFRESH_TOKEN_TYPE = "refresh";
    static final long ACCESS_TOKEN_EXPIRY_MINUTES = 15;
    static final long REFRESH_TOKEN_EXPIRY_DAYS = 7;


    @NonFinal
    @Value("${spring.jwt.signerKey}")
    String signerKey;

    public LoginResponse login(LoginRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        boolean authenticated = passwordEncoder.matches(request.getPassword(), user.getPassword());

        if (!authenticated) {
            throw new AppException(ErrorCode.AUTHENTICATION_FAILED);
        }

        return buildLoginResponse(user);
    }

    public LoginResponse refreshToken(RefreshTokenRequest request) throws ParseException, JOSEException {
        SignedJWT signedJWT = verifytoken(request.getRefreshToken(), REFRESH_TOKEN_TYPE);
        String email = signedJWT.getJWTClaimsSet().getSubject();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        RefreshToken refreshToken = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new AppException(ErrorCode.INVALID_REFRESH_TOKEN));
        refreshToken.setRevoked(true);
        refreshTokenRepository.save(refreshToken);

        return buildLoginResponse(user);
    }

    private LoginResponse buildLoginResponse(User user) {
        profileService.ensureProfileExists(user);

        String accessToken = generateToken(user, ACCESS_TOKEN_TYPE);
        String refreshToken = generateToken(user, REFRESH_TOKEN_TYPE);
        saveRefreshToken(user, refreshToken);

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .accessTokenExpiresIn(ACCESS_TOKEN_EXPIRY_MINUTES * 60)
                .refreshTokenExpiresIn(REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60)
                .authenticated(true)
                .build();
    }

    private void saveRefreshToken(User user, String refreshToken) {
        Instant now = Instant.now();
        refreshTokenRepository.save(RefreshToken.builder()
                .token(refreshToken)
                .userId(user.getId())
                .issueTime(Date.from(now))
                .expireTime(Date.from(now.plus(REFRESH_TOKEN_EXPIRY_DAYS, ChronoUnit.DAYS)))
                .revoked(false)
                .build());
    }

    private String generateToken(User user, String tokenType) {
        Instant now = Instant.now();
        Instant expiration = ACCESS_TOKEN_TYPE.equals(tokenType)
                ? now.plus(ACCESS_TOKEN_EXPIRY_MINUTES, ChronoUnit.MINUTES)
                : now.plus(REFRESH_TOKEN_EXPIRY_DAYS, ChronoUnit.DAYS);

        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(user.getEmail())
                .issuer("demo1")
                .issueTime(Date.from(now))
                .expirationTime(Date.from(expiration))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .claim("token_type", tokenType)
                .build();

        JWSObject jwsObject = new JWSObject(
                new JWSHeader(JWSAlgorithm.HS512),
                new Payload(jwtClaimsSet.toJSONObject())
        );

        try {
            jwsObject.sign(new MACSigner(signerKey.getBytes()));
            return jwsObject.serialize();
        } catch (JOSEException e) {
            log.error("Cannot create token", e);
            throw new AppException(ErrorCode.FAILED_TOKEN);
        }
    }

    private SignedJWT verifytoken(String token) throws JOSEException, ParseException {
        return verifytoken(token, null);
    }

    private SignedJWT verifytoken(String token, String expectedTokenType) throws JOSEException, ParseException {
        JWSVerifier verifier = new MACVerifier(signerKey.getBytes());
        SignedJWT signedJWT = SignedJWT.parse(token);
        Date expiryTime = signedJWT.getJWTClaimsSet().getExpirationTime();
        boolean verified = signedJWT.verify(verifier);

        if (!(verified && expiryTime.after(new Date()))) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        if (expectedTokenType != null) {
            Object tokenType = signedJWT.getJWTClaimsSet().getClaim("token_type");
            if (!expectedTokenType.equals(tokenType)) {
                if (REFRESH_TOKEN_TYPE.equals(expectedTokenType)) {
                    throw new AppException(ErrorCode.INVALID_REFRESH_TOKEN);
                }
                throw new AppException(ErrorCode.UNAUTHORIZED);
            }
        }

        if (REFRESH_TOKEN_TYPE.equals(expectedTokenType)) {
            RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                    .orElseThrow(() -> new AppException(ErrorCode.INVALID_REFRESH_TOKEN));

            if (refreshToken.isRevoked()) {
                throw new AppException(ErrorCode.REFRESH_TOKEN_ALREADY_USED_OR_REVOKED);
            }

            if (refreshToken.getExpireTime().before(new Date())) {
                throw new AppException(ErrorCode.INVALID_REFRESH_TOKEN);
            }
        }

        return signedJWT;
    }

    public IntrospectResponse introspect(IntrospectRequest request) throws ParseException, JOSEException {
        boolean isValid = true;
        try {
            verifytoken(request.getToken(), ACCESS_TOKEN_TYPE);
        } catch (AppException e) {
            isValid = false;
        }

        return IntrospectResponse.builder()
                .valid(isValid)
                .build();
    }

    private String buildScope(User user) {
        StringJoiner stringJoiner = new StringJoiner(" ");
        if (!CollectionUtils.isEmpty(user.getRoles())) {
            user.getRoles().forEach(role -> {
                stringJoiner.add("ROLE_" + role.getName());
                if (!CollectionUtils.isEmpty(role.getPermissions())) {
                    role.getPermissions().forEach(permission -> stringJoiner.add(permission.getName()));
                }
            });
        }
        return stringJoiner.toString();
    }
    public void logout(LogoutRequest request) throws ParseException, JOSEException {
        SignedJWT signedJWT = verifytoken(request.getToken());
        Object tokenType = signedJWT.getJWTClaimsSet().getClaim("token_type");
        if (REFRESH_TOKEN_TYPE.equals(tokenType)) {
            RefreshToken refreshToken = refreshTokenRepository.findByToken(request.getToken())
                    .orElseThrow(() -> new AppException(ErrorCode.INVALID_REFRESH_TOKEN));
            refreshToken.setRevoked(true);
            refreshTokenRepository.save(refreshToken);
        }
    }

}
