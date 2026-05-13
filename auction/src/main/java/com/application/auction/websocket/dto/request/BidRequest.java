package com.application.auction.websocket.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * DTO representing a bid request from a client.
 *
 * @param auctionId The ID of the auction to bid on.
 * @param amount    The amount of the bid.
 */
public record BidRequest(
        @NotNull UUID auctionId,
        @NotNull @Positive BigDecimal amount
) {
}
