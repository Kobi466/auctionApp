package com.application.auction.websocket.exception;

public class InsufficientBidException extends RuntimeException {
    public InsufficientBidException(String message) {
        super(message);
    }
}
