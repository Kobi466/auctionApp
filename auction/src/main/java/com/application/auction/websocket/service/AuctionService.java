package com.application.auction.websocket.service;

import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.User;
import com.application.auction.repository.AuctionRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.websocket.dto.event.AuctionUpdateEvent;
import com.application.auction.websocket.dto.event.BidEvent;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import com.application.auction.websocket.enums.EventType;
import com.application.auction.websocket.exception.AuctionEndedException;
import com.application.auction.websocket.exception.AuctionNotFoundException;
import com.application.auction.websocket.exception.InsufficientBidException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuctionService {

    private final AuctionRepository auctionRepository;
    private final BidRepository bidRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    // Constants for anti-sniping logic
    private static final long ANTI_SNIPING_THRESHOLD_SECONDS = 30;
    private static final long ANTI_SNIPING_EXTENSION_SECONDS = 30;

    @Transactional
    public void placeBid(UUID auctionId, BigDecimal amount, String username) {
        // Step 1: Lock the auction row for the duration of the transaction to prevent race conditions.
        AuctionRoom auction = auctionRepository.findByIdForUpdate(auctionId)
                .orElseThrow(() -> new AuctionNotFoundException("Auction not found with ID: " + auctionId));

        User bidder = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        // Step 2: Validate auction status and bid amount.
        validateAuctionAndBid(auction, amount);

        User previousHighestBidder = auction.getHighestBidder();

        // Step 3: Save the new bid.
        Bid newBid = createAndSaveBid(auction, bidder, amount);

        // Step 4: Update the auction state.
        auction.setCurrentPrice(amount);
        auction.setHighestBidder(bidder);

        // Step 5: Handle anti-sniping logic.
        boolean wasExtended = handleAntiSniping(auction);

        // The transaction will commit here, saving the auction and releasing the lock.

        // --- Post-Transaction Events ---
        // These are called after the transaction is successfully committed.

        // Step 6: Broadcast updates to all clients.
        broadcastNewBid(auction, newBid);
        broadcastAuctionUpdate(auction, wasExtended);

        // Step 7: Notify the previously highest bidder that they have been outbid.
        if (previousHighestBidder != null && !previousHighestBidder.getId().equals(bidder.getId())) {
            notificationService.notifyOutbid(previousHighestBidder.getUsername(), auctionId);
        }
    }

    private void validateAuctionAndBid(AuctionRoom auction, BigDecimal amount) {
        if (auction.getStatus() != AuctionRoomStatus.LIVE) {
            throw new AuctionEndedException("Auction is not active.");
        }
        if (Instant.now().isAfter(auction.getEndTime())) {
            throw new AuctionEndedException("Auction has already ended.");
        }
        if (amount.compareTo(auction.getCurrentPrice()) <= 0) {
            throw new InsufficientBidException("Bid amount must be greater than the current price of " + auction.getCurrentPrice());
        }
    }

    private Bid createAndSaveBid(AuctionRoom auction, User bidder, BigDecimal amount) {
        Bid newBid = new Bid();
        newBid.setAuctionRoom(auction);
        newBid.setBidder(bidder);
        newBid.setAmount(amount);
        newBid.setTimestamp(Instant.now());
        return bidRepository.save(newBid);
    }

    private boolean handleAntiSniping(AuctionRoom auction) {
        long secondsUntilEnd = Duration.between(Instant.now(), auction.getEndTime()).getSeconds();
        if (secondsUntilEnd > 0 && secondsUntilEnd <= ANTI_SNIPING_THRESHOLD_SECONDS) {
            auction.setEndTime(auction.getEndTime().plusSeconds(ANTI_SNIPING_EXTENSION_SECONDS));
            log.info("Auction {} extended by {} seconds due to anti-sniping.", auction.getId(), ANTI_SNIPING_EXTENSION_SECONDS);
            return true;
        }
        return false;
    }

    private void broadcastNewBid(AuctionRoom auction, Bid bid) {
        BidEvent bidEvent = new BidEvent(
                EventType.NEW_BID,
                auction.getId(),
                bid.getBidder().getId(),
                bid.getBidder().getUsername(), // Assuming User has a getFullName() method
                bid.getAmount(),
                bid.getTimestamp()
        );
        String topic = "/topic/auction/" + auction.getId() + "/bids";
        messagingTemplate.convertAndSend(topic, bidEvent);
        log.debug("Broadcast to {}: {}", topic, bidEvent);
    }

    private void broadcastAuctionUpdate(AuctionRoom auction, boolean wasExtended) {
        AuctionUpdateEvent updateEvent = new AuctionUpdateEvent(
                wasExtended ? EventType.AUCTION_EXTENDED : EventType.NEW_BID,
                auction.getId(),
                auction.getCurrentPrice(),
                auction.getHighestBidder().getId(),
                auction.getHighestBidder().getUsername(),
                auction.getEndTime()
        );
        String topic = "/topic/auction/" + auction.getId();
        messagingTemplate.convertAndSend(topic, updateEvent);
        log.debug("Broadcast to {}: {}", topic, updateEvent);
    }
}
