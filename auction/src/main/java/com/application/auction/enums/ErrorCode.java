package com.application.auction.enums;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;

@Getter
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(500, "Uncategorized exception", HttpStatus.INTERNAL_SERVER_ERROR),
    VALIDATION_ERROR(400, "Validation error", HttpStatus.BAD_REQUEST),
    GENERATED_TOKEN_FAILED(401, "Generated token faild", HttpStatus.BAD_REQUEST),
    VERIFY_TOKEN_FAILED(402, "Verify token faild", HttpStatus.BAD_REQUEST),
    AUTHENTICATION_FAILED(207, "Authentication failed", HttpStatus.UNAUTHORIZED),
    INVALID_KEY(403, "Invalid key", HttpStatus.BAD_REQUEST),
    REFRESH_TOKEN_NOT_FOUND(404, "Refresh token not found", HttpStatus.NOT_FOUND),
    REFRESH_TOKEN_EXPIRED(405, "Refresh token expired", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_FAILED(406, "Refresh token was used or expired", HttpStatus.UNAUTHORIZED),
    INVALID_ACCESS_TOKEN(407, "Invalid access token", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(408, "Unauthorized", HttpStatus.UNAUTHORIZED),
    USER_NOT_FOUND(417, "User not found", HttpStatus.NOT_FOUND),
    EMAIL_ALREADY_EXISTS(418, "Email already exists", HttpStatus.BAD_REQUEST),
    INVALID_OTP(418, "Invalid OTP", HttpStatus.BAD_REQUEST),
    USER_EXISTS(419, "User exists", HttpStatus.BAD_REQUEST),
    ROLE_NOT_FOUND(420, "Role not found", HttpStatus.NOT_FOUND),
    ACCESS_TOKEN_FAILED(421, "Access token failed", HttpStatus.UNAUTHORIZED),
    FAILED_TOKEN(422, "Failed token", HttpStatus.UNAUTHORIZED),
    PROFILE_NOT_FOUND(423, "Profile not found", HttpStatus.NOT_FOUND),
    KYC_DETAIL_NOT_FOUND(424, "KYC detail not found", HttpStatus.NOT_FOUND),
    INVALID_REFRESH_TOKEN(425, "Invalid refresh token", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_ALREADY_USED_OR_REVOKED(426, "Refresh token already used or revoked", HttpStatus.UNAUTHORIZED),
    PHONE_NUMBER_ALREADY_EXISTS(427, "Phone number already exists", HttpStatus.BAD_REQUEST),
    FULL_NAME_ALREADY_EXISTS(428, "Full name already exists", HttpStatus.BAD_REQUEST),
    KYC_ID_NUMBER_ALREADY_EXISTS(429, "KYC id number already exists", HttpStatus.BAD_REQUEST),
    KYC_DOCUMENT_REQUIRED(430, "KYC documents are required", HttpStatus.BAD_REQUEST),
    KYC_REJECT_REASON_REQUIRED(431, "Rejected reason is required", HttpStatus.BAD_REQUEST),
    KYC_VERIFICATION_REQUIRED(432, "KYC verification is required", HttpStatus.FORBIDDEN),
    KYC_INFORMATION_REQUIRED(433, "KYC personal information is required", HttpStatus.BAD_REQUEST);

    int code;
    String message;
    HttpStatus status;

    ErrorCode(int code, String message, HttpStatus status) {
        this.code = code;
        this.message = message;
        this.status = status;
    }
}
