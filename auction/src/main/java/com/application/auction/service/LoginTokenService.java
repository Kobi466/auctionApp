package com.application.auction.service;

import com.application.auction.entity.RefreshToken;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.RefreshTokenRepository;
import com.application.auction.repository.UserRepository;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSObject;
import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.Payload;
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
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.StringJoiner;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class LoginTokenService {

    static final String ACCESS_TOKEN_TYPE = "access";
    static final String REFRESH_TOKEN_TYPE = "refresh";
    static final long ACCESS_TOKEN_EXPIRY_MINUTES = 15;
    static final long REFRESH_TOKEN_EXPIRY_DAYS = 7;

    RefreshTokenRepository refreshTokenRepository;
    UserRepository userRepository;

    @NonFinal
    @Value("${jwt.secret}")
    String signerKey;

    public String generateToken(User user, String tokenType) {
        Instant now = Instant.now();
        Instant expiration = ACCESS_TOKEN_TYPE.equals(tokenType)
                ? now.plus(ACCESS_TOKEN_EXPIRY_MINUTES, ChronoUnit.MINUTES)
                : now.plus(REFRESH_TOKEN_EXPIRY_DAYS, ChronoUnit.DAYS);

        JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
                .subject(user.getEmail())
                .issuer("demo1")
                .issueTime(Date.from(now))
                .expirationTime(Date.from(expiration))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .claim("token_type", tokenType)
                .build();

        JWSObject jwsObject = new JWSObject(new JWSHeader(JWSAlgorithm.HS256), new Payload(claimsSet.toJSONObject()));
        try {
            jwsObject.sign(new MACSigner(signerKey.getBytes()));
            return jwsObject.serialize();
        } catch (JOSEException e) {
            log.error("Cannot create token", e);
            throw new AppException(ErrorCode.FAILED_TOKEN);
        }
    }

    public SignedJWT verifyToken(String token) throws JOSEException, ParseException {
        return verifyToken(token, null);
    }

    public SignedJWT verifyToken(String token, String expectedTokenType) throws JOSEException, ParseException {
        JWSVerifier verifier = new MACVerifier(signerKey.getBytes());
        SignedJWT signedJWT = SignedJWT.parse(token);
        Date expiryTime = signedJWT.getJWTClaimsSet().getExpirationTime();
        if (!(signedJWT.verify(verifier) && expiryTime.after(new Date()))) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        validateTokenType(signedJWT, expectedTokenType);
        if (REFRESH_TOKEN_TYPE.equals(expectedTokenType)) {
            validateRefreshToken(token);
        }
        ensureSubjectActive(signedJWT);
        return signedJWT;
    }

    public void saveRefreshToken(User user, String refreshToken) {
        Instant now = Instant.now();
        refreshTokenRepository.save(RefreshToken.builder()
                .token(refreshToken)
                .userId(user.getId())
                .issueTime(Date.from(now))
                .expireTime(Date.from(now.plus(REFRESH_TOKEN_EXPIRY_DAYS, ChronoUnit.DAYS)))
                .revoked(false)
                .build());
    }

    public Set<String> extractRoleNames(User user) {
        Set<String> roleNames = new LinkedHashSet<>();
        if (!CollectionUtils.isEmpty(user.getRoles())) {
            user.getRoles().forEach(role -> roleNames.add(role.getName()));
        }
        return roleNames;
    }

    private void validateTokenType(SignedJWT signedJWT, String expectedTokenType) throws ParseException {
        if (expectedTokenType == null) return;
        Object tokenType = signedJWT.getJWTClaimsSet().getClaim("token_type");
        if (expectedTokenType.equals(tokenType)) return;
        if (REFRESH_TOKEN_TYPE.equals(expectedTokenType)) {
            throw new AppException(ErrorCode.INVALID_REFRESH_TOKEN);
        }
        throw new AppException(ErrorCode.UNAUTHORIZED);
    }

    private void validateRefreshToken(String token) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> new AppException(ErrorCode.INVALID_REFRESH_TOKEN));
        if (refreshToken.isRevoked()) {
            throw new AppException(ErrorCode.REFRESH_TOKEN_ALREADY_USED_OR_REVOKED);
        }
        if (refreshToken.getExpireTime().before(new Date())) {
            throw new AppException(ErrorCode.INVALID_REFRESH_TOKEN);
        }
    }

    private void ensureSubjectActive(SignedJWT signedJWT) throws ParseException {
        String email = signedJWT.getJWTClaimsSet().getSubject();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        if (!user.isActive()) {
            throw new AppException(ErrorCode.ACCOUNT_LOCKED);
        }
    }

    private String buildScope(User user) {
        StringJoiner joiner = new StringJoiner(" ");
        if (!CollectionUtils.isEmpty(user.getRoles())) {
            user.getRoles().forEach(role -> {
                joiner.add("ROLE_" + role.getName());
                if (!CollectionUtils.isEmpty(role.getPermissions())) {
                    role.getPermissions().forEach(permission -> joiner.add(permission.getName()));
                }
            });
        }
        return joiner.toString();
    }
}
