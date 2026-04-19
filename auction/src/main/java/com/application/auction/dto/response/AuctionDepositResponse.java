package com.application.auction.dto.response;

import com.application.auction.enums.AuctionDepositStatus;
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
public class AuctionDepositResponse {
    UUID id;
    UUID auctionRoomId;
    UUID productId;
    UUID userId;
    BigDecimal requiredAmount;
    String transferContent;
    AuctionDepositStatus status;
    String adminNote;
    String userNote;
    Instant paymentSubmittedAt;
    Instant approvedAt;
    Instant createdAt;
    Instant updatedAt;
}
