package com.application.auction.dto.response;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AuctionRoomSummaryResponse {
    ProductResponse product;
    BigDecimal currentPrice;
    long bidCount;
    long watcherCount;
    List<AuctionParticipantResponse> participants;
    List<BidResponse> bids;
}
