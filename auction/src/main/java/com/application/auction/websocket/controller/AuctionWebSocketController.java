package com.application.auction.websocket.controller;

import com.application.auction.websocket.dto.request.BidRequest;
import com.application.auction.websocket.exception.BidCooldownException;
import com.application.auction.websocket.service.AuctionService;
import com.application.auction.websocket.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
@Slf4j
public class AuctionWebSocketController {

    private final AuctionService auctionService;
    private final NotificationService notificationService;

    @MessageMapping("/auction/bid")
    public void handleBid(@Payload @Valid BidRequest bidRequest, Principal principal) {
        if (principal == null) {
            log.error("Cannot place bid without an authenticated user.");
            return;
        }

        String email = principal.getName();
        log.info(
                "Received websocket bid from '{}' for auction '{}' with amount {}",
                email,
                bidRequest.auctionId(),
                bidRequest.amount()
        );

        try {
            auctionService.placeBid(bidRequest.auctionId(), bidRequest.amount(), email);
        } catch (BidCooldownException e) {
            log.warn("Bid cooldown active for '{}': {}", email, e.getMessage());
            notificationService.sendErrorToUser(email, e.getMessage());
        } catch (Exception e) {
            log.error("Error processing websocket bid for '{}': {}", email, e.getMessage(), e);
            notificationService.sendErrorToUser(email, e.getMessage());
        }
    }

    @MessageExceptionHandler
    public void handleException(Exception exception, Principal principal) {
        if (principal != null) {
            log.error("WebSocket error for user '{}': {}", principal.getName(), exception.getMessage());
            notificationService.sendErrorToUser(principal.getName(), "An error occurred: " + exception.getMessage());
            return;
        }

        log.error("WebSocket error for an unauthenticated user: {}", exception.getMessage());
    }
}
