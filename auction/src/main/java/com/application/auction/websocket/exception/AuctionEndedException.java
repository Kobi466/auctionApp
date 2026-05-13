package com.application.auction.websocket.exception;

public class AuctionEndedException extends RuntimeException {
    public AuctionEndedException(String message) {
        super(message);
    }
}
