package com.application.auction.websocket.dto.event;

import com.application.auction.websocket.enums.EventType;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Event broadcast when a new bid is successfully placed.
 * This is typically used to update the bid history list.
 */
public record BidEvent(
        EventType type,
        UUID auctionId,
        UUID bidderId,
        String bidderName,
        BigDecimal amount,
        Instant timestamp
) {
}
