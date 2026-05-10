package com.application.auction.dto.response;

import com.application.auction.enums.WithdrawalStatus;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class WithdrawalResponse {
    UUID id;
    UUID userId;
    String username;
    String userEmail;
    String userFullName;
    BigDecimal amount;
    String bankName;
    String accountNumber;
    String accountHolderName;
    String branchName;
    String userNote;
    String adminNote;
    WithdrawalStatus status;
    Instant requestedAt;
    Instant reviewedAt;
    Instant completedAt;
    Instant createdAt;
    Instant updatedAt;
}
