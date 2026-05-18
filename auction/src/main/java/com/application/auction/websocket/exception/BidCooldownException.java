package com.application.auction.websocket.exception;

public class BidCooldownException extends RuntimeException {
    public BidCooldownException(String message) {
        super(message);
    }
}
