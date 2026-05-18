package com.application.auction.dto.response;

import com.application.auction.websocket.enums.AuctionRoomStatus;
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
public class AuctionRoomResponse {
    UUID id;
    UUID productId;
    String roomCode;
    String roomPassword;
    BigDecimal minimumBid;
    BigDecimal depositAmount;
    Instant startTime;
    Instant endTime;
    AuctionRoomStatus status;
    Integer currentWinnerRank;
    String winnerPaymentStatus;
    String winnerPaymentReceiptUrl;
    String winnerPaymentUserNote;
    String winnerPaymentAdminNote;
    Integer winnerPaymentRejectedCount;
    Instant winnerPaymentSubmittedAt;
    Instant winnerPaymentConfirmedAt;
    Instant createdAt;
    Instant updatedAt;
}
