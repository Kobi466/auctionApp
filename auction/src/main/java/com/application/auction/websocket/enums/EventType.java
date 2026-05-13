package com.application.auction.websocket.enums;

public enum EventType {
    /**
     * A new bid has been placed.
     */
    NEW_BID,

    /**
     * A user has been outbid by another user. (Private notification)
     */
    OUTBID,

    /**
     * The auction time has been extended due to a last-minute bid (anti-sniping).
     */
    AUCTION_EXTENDED,

    /**
     * The auction has officially ended.
     */
    AUCTION_ENDED,

    /**
     * An error occurred during an operation (e.g., invalid bid). (Private notification)
     */
    ERROR
}
