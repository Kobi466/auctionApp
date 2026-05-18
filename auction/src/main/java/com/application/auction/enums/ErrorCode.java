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
    KYC_INFORMATION_REQUIRED(433, "KYC personal information is required", HttpStatus.BAD_REQUEST),
    PRODUCT_NOT_FOUND(434, "Product not found", HttpStatus.NOT_FOUND),
    AUCTION_ROOM_NOT_FOUND(435, "Auction room not found", HttpStatus.NOT_FOUND),
    PRODUCT_NAME_REQUIRED(436, "Product name is required", HttpStatus.BAD_REQUEST),
    PRODUCT_BRAND_REQUIRED(437, "Product brand is required", HttpStatus.BAD_REQUEST),
    PRODUCT_CATEGORY_REQUIRED(438, "Product category is required", HttpStatus.BAD_REQUEST),
    PRODUCT_IMAGES_REQUIRED(440, "At least one product image is required", HttpStatus.BAD_REQUEST),
    AUCTION_MINIMUM_BID_REQUIRED(441, "Minimum bid must be greater than zero", HttpStatus.BAD_REQUEST),
    AUCTION_DEPOSIT_INVALID(442, "Deposit amount must be greater than zero", HttpStatus.BAD_REQUEST),
    AUCTION_SCHEDULE_INVALID(443, "Auction schedule is invalid", HttpStatus.BAD_REQUEST),
    AUCTION_PAYMENT_CONFIG_REQUIRED(444, "Auction payment configuration is required", HttpStatus.BAD_REQUEST),
    AUCTION_DEPOSIT_NOT_FOUND(445, "Auction deposit not found", HttpStatus.NOT_FOUND),
    AUCTION_DEPOSIT_REQUIRED(446, "Auction deposit is required", HttpStatus.BAD_REQUEST),
    AUCTION_DEPOSIT_APPROVAL_REQUIRED(447, "Auction deposit approval is required", HttpStatus.FORBIDDEN),
    AUCTION_DEPOSIT_STATUS_INVALID(448, "Auction deposit status is invalid", HttpStatus.BAD_REQUEST),
    AUCTION_DEPOSIT_REVIEW_INVALID(449, "Auction deposit review status is invalid", HttpStatus.BAD_REQUEST),
    AUCTION_ROOM_ALREADY_EXISTS(450, "Auction room already exists for this product", HttpStatus.BAD_REQUEST),
    ACCOUNT_LOCKED(451, "Account is locked", HttpStatus.FORBIDDEN),
    USER_STATUS_REQUIRED(452, "User status is required", HttpStatus.BAD_REQUEST),
    CANNOT_LOCK_SELF(453, "Admin cannot lock own account", HttpStatus.BAD_REQUEST),
    NOTIFICATION_NOT_FOUND(454, "Notification not found", HttpStatus.NOT_FOUND),
    AUCTION_ROOM_NOT_STARTED(455, "Auction registration is not open yet", HttpStatus.BAD_REQUEST),
    AUCTION_ROOM_CLOSED(456, "Auction room has ended", HttpStatus.BAD_REQUEST),
    AUCTION_ROOM_ALREADY_STARTED(457, "Auction room has already started", HttpStatus.BAD_REQUEST),
    WITHDRAWAL_NOT_FOUND(458, "Withdrawal request not found", HttpStatus.NOT_FOUND),
    WITHDRAWAL_AMOUNT_INVALID(459, "Withdrawal amount is invalid", HttpStatus.BAD_REQUEST),
    WITHDRAWAL_BALANCE_NOT_ENOUGH(460, "Withdrawable balance is not enough", HttpStatus.BAD_REQUEST),
    WITHDRAWAL_BANK_REQUIRED(461, "Withdrawal bank information is required", HttpStatus.BAD_REQUEST),
    WITHDRAWAL_STATUS_INVALID(462, "Withdrawal status is invalid", HttpStatus.BAD_REQUEST),
    WITHDRAWAL_REVIEW_INVALID(463, "Withdrawal review is invalid", HttpStatus.BAD_REQUEST),
    BID_AMOUNT_INVALID(464, "Bid amount is invalid", HttpStatus.BAD_REQUEST),
    BID_COOLDOWN_ACTIVE(465, "Please wait 5 seconds before placing another bid", HttpStatus.BAD_REQUEST),
    AUCTION_ROOM_NOT_ENDED(466, "Auction room has not ended yet", HttpStatus.BAD_REQUEST);

    int code;
    String message;
    HttpStatus status;

    ErrorCode(int code, String message, HttpStatus status) {
        this.code = code;
        this.message = message;
        this.status = status;
    }
}
