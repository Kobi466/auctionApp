//package com.application.auction.websocket.controller;
//
//import com.application.auction.websocket.dto.request.BidRequest;
//import com.application.auction.websocket.service.AuctionService;
//import com.application.auction.websocket.service.NotificationService;
//import jakarta.validation.Valid;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
//import org.springframework.messaging.handler.annotation.MessageMapping;
//import org.springframework.messaging.handler.annotation.Payload;
//import org.springframework.stereotype.Controller;
//
//import java.security.Principal;
//
//@Controller
//@RequiredArgsConstructor
//@Slf4j
//public class AuctionWebSocketController {
//
//    private final AuctionService auctionService;
//    private final NotificationService notificationService;
//
//    /**
//     * Handles incoming bid requests from clients.
//     * The Principal is automatically injected by Spring Security after successful authentication
//     * via the WebSocket interceptor. We NEVER trust user identity from the client payload.
//     *
//     * @param bidRequest The bid request payload.
//     * @param principal  The authenticated user principal.
//     */
//    @MessageMapping("/auction/bid")
//    public void handleBid(@Payload @Valid BidRequest bidRequest, Principal principal) {
//        if (principal == null) {
//            log.error("Cannot place bid without an authenticated user.");
//            // In a real scenario, the interceptor should prevent this, but as a safeguard:
//            return;
//        }
//        String username = principal.getName();
//        log.info("Received bid from user '{}' for auction '{}' with amount {}", username, bidRequest.auctionId(), bidRequest.amount());
//        try {
//            auctionService.placeBid(bidRequest.auctionId(), bidRequest.amount(), username);
//        } catch (Exception e) {
//            // Catching specific exceptions is better, but for a central point:
//            log.error("Error processing bid for user '{}': {}", username, e.getMessage(), e);
//            // Send a private error message back to the user who sent the bid.
//            notificationService.sendErrorToUser(username, e.getMessage());
//        }
//    }
//
//    /**
//     * A centralized exception handler for this controller.
//     * Catches exceptions from @MessageMapping methods and sends a private error
//     * notification to the user who triggered the error.
//     *
//     * @param exception The exception that was thrown.
//     * @param principal The user for whom the exception occurred.
//     */
//    @MessageExceptionHandler
//    public void handleException(Exception exception, Principal principal) {
//        if (principal != null) {
//            log.error("WebSocket error for user '{}': {}", principal.getName(), exception.getMessage());
//            notificationService.sendErrorToUser(principal.getName(), "An error occurred: " + exception.getMessage());
//        } else {
//            log.error("WebSocket error for an unauthenticated user: {}", exception.getMessage());
//        }
//    }
//}
