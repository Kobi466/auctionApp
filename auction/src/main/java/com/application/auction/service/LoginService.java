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
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jwt.SignedJWT;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.util.Set;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class LoginService {

    UserRepository userRepository;
    RefreshTokenRepository refreshTokenRepository;
    ProfileService profileService;
    LoginTokenService tokenService;

    public LoginResponse login(LoginRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        User user = userRepository.findWithRolesByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        ensureUserActive(user);

        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.AUTHENTICATION_FAILED);
        }
        return buildLoginResponse(user);
    }

    public LoginResponse refreshToken(RefreshTokenRequest request) throws ParseException, JOSEException {
        SignedJWT signedJWT = tokenService.verifyToken(
                request.getRefreshToken(),
                LoginTokenService.REFRESH_TOKEN_TYPE
        );
        User user = userRepository.findByEmail(signedJWT.getJWTClaimsSet().getSubject())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        ensureUserActive(user);
        revokeRefreshToken(request.getRefreshToken());
        return buildLoginResponse(user);
    }

    public IntrospectResponse introspect(IntrospectRequest request) throws ParseException, JOSEException {
        boolean valid = true;
        try {
            tokenService.verifyToken(request.getToken(), LoginTokenService.ACCESS_TOKEN_TYPE);
        } catch (AppException e) {
            valid = false;
        }
        return IntrospectResponse.builder().valid(valid).build();
    }

    public void logout(LogoutRequest request) throws ParseException, JOSEException {
        SignedJWT signedJWT = tokenService.verifyToken(request.getToken());
        Object tokenType = signedJWT.getJWTClaimsSet().getClaim("token_type");
        if (LoginTokenService.REFRESH_TOKEN_TYPE.equals(tokenType)) {
            revokeRefreshToken(request.getToken());
        }
    }

    private LoginResponse buildLoginResponse(User user) {
        ensureUserActive(user);
        profileService.ensureProfileExists(user);

        String accessToken = tokenService.generateToken(user, LoginTokenService.ACCESS_TOKEN_TYPE);
        String refreshToken = tokenService.generateToken(user, LoginTokenService.REFRESH_TOKEN_TYPE);
        tokenService.saveRefreshToken(user, refreshToken);
        Set<String> roleNames = tokenService.extractRoleNames(user);

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .accessTokenExpiresIn(LoginTokenService.ACCESS_TOKEN_EXPIRY_MINUTES * 60)
                .refreshTokenExpiresIn(LoginTokenService.REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60)
                .authenticated(true)
                .roles(roleNames)
                .admin(roleNames.contains("ADMIN"))
                .build();
    }

    private void revokeRefreshToken(String token) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> new AppException(ErrorCode.INVALID_REFRESH_TOKEN));
        refreshToken.setRevoked(true);
        refreshTokenRepository.save(refreshToken);
    }

    private void ensureUserActive(User user) {
        if (!user.isActive()) {
            throw new AppException(ErrorCode.ACCOUNT_LOCKED);
        }
    }
}
