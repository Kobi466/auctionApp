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
public class AdminWinnerResponse {
    UUID id;
    String productName;
    String winnerName;
    String statusLabel;
    String subStatusLabel;
    BigDecimal price;
    Instant winningTime;
    String imageUrl;
    String status;
}
