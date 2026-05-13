package com.application.auction.websocket.dto.event;

import com.application.auction.websocket.enums.EventType;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Event broadcast to update the general state of the auction.
 * This includes changes in price, highest bidder, and end time.
 */
public record AuctionUpdateEvent(
        EventType type,
        UUID auctionId,
        BigDecimal currentPrice,
        UUID highestBidderId,
        String highestBidderName,
        Instant endTime
) {
}
