package com.application.auction.websocket.dto.event;

import com.application.auction.websocket.enums.EventType;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.UUID;

/**
 * Event sent to a specific user for private notifications, such as being outbid or encountering an error.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record NotificationEvent(
        EventType type,
        String message,
        UUID auctionId
) {
}
