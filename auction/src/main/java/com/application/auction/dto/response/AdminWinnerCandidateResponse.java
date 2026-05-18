package com.application.auction.dto.response;

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
public class AdminWinnerCandidateResponse {
    int rank;
    UUID userId;
    String userName;
    String userEmail;
    BigDecimal amount;
    Instant bidTime;
    boolean winner;
    String depositStatus;
    boolean activeOffer;
    String winnerPaymentStatus;
    String winnerPaymentReceiptUrl;
    String winnerPaymentUserNote;
    String winnerPaymentAdminNote;
    Integer winnerPaymentRejectedCount;
    Instant winnerPaymentSubmittedAt;
}
