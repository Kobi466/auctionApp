package com.application.auction.websocket.service;

import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.User;
import com.application.auction.repository.AuctionRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.util.PrivacyMaskingUtil;
import com.application.auction.websocket.dto.event.AuctionUpdateEvent;
import com.application.auction.websocket.dto.event.BidEvent;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import com.application.auction.websocket.enums.EventType;
import com.application.auction.websocket.exception.AuctionEndedException;
import com.application.auction.websocket.exception.AuctionNotFoundException;
import com.application.auction.websocket.exception.BidCooldownException;
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
    private final ProfileRepository profileRepository;
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    // Last-minute extension is applied once per auction room.
    private static final long LAST_MINUTE_EXTENSION_THRESHOLD_SECONDS = 60;
    private static final long LAST_MINUTE_EXTENSION_SECONDS = 120;
    private static final long BID_COOLDOWN_SECONDS = 5;

    @Transactional
    public void placeBid(UUID auctionId, BigDecimal incrementAmount, String email) {
        // Step 1: Lock the auction row for the duration of the transaction to prevent race conditions.
        AuctionRoom auction = auctionRepository.findByIdForUpdate(auctionId)
                .orElseThrow(() -> new AuctionNotFoundException("Auction not found with ID: " + auctionId));

        User bidder = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

        // Step 2: Validate auction status and bid increment amount.
        validateAuctionAndBid(auction, incrementAmount);
        validateBidCooldown(auction, bidder);
        BigDecimal newPrice = getCurrentPrice(auction).add(incrementAmount);

        User previousHighestBidder = auction.getHighestBidder();

        // Step 3: Save the new bid.
        Bid newBid = createAndSaveBid(auction, bidder, newPrice);

        // Step 4: Update the auction state.
        auction.setCurrentPrice(newPrice);
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
            notificationService.notifyOutbid(previousHighestBidder.getEmail(), auctionId);
        }
    }

    private void validateAuctionAndBid(AuctionRoom auction, BigDecimal incrementAmount) {
        Instant now = Instant.now();
        if (auction.getStatus() == AuctionRoomStatus.CANCELLED) {
            throw new AuctionEndedException("Auction has been cancelled.");
        }
        if (auction.getStartTime() != null && now.isBefore(auction.getStartTime())) {
            throw new AuctionEndedException("Auction has not started yet.");
        }
        if (auction.getEndTime() != null && now.isAfter(auction.getEndTime())) {
            auction.setStatus(AuctionRoomStatus.CLOSED);
            throw new AuctionEndedException("Auction has already ended.");
        }
        if (auction.getStatus() != AuctionRoomStatus.LIVE) {
            auction.setStatus(AuctionRoomStatus.LIVE);
        }
        if (incrementAmount == null || incrementAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new InsufficientBidException("Bid increment must be greater than zero.");
        }
    }

    private BigDecimal getCurrentPrice(AuctionRoom auction) {
        if (auction.getCurrentPrice() != null) {
            return auction.getCurrentPrice();
        }
        if (auction.getStartingPrice() != null) {
            return auction.getStartingPrice();
        }
        return BigDecimal.ZERO;
    }

    private Bid createAndSaveBid(AuctionRoom auction, User bidder, BigDecimal amount) {
        Bid newBid = new Bid();
        newBid.setAuctionRoom(auction);
        newBid.setBidder(bidder);
        newBid.setAmount(amount);
        newBid.setTimestamp(Instant.now());
        return bidRepository.save(newBid);
    }

    private void validateBidCooldown(AuctionRoom auction, User bidder) {
        Instant cooldownStart = Instant.now().minusSeconds(BID_COOLDOWN_SECONDS);
        bidRepository.findTopByAuctionRoomIdAndBidderIdOrderByTimestampDesc(auction.getId(), bidder.getId())
                .filter(lastBid -> lastBid.getTimestamp() != null && lastBid.getTimestamp().isAfter(cooldownStart))
                .ifPresent(lastBid -> {
                    throw new BidCooldownException("Please wait 5 seconds before placing another bid.");
                });
    }

    private boolean handleAntiSniping(AuctionRoom auction) {
        if (auction.isTimeExtended() || auction.getEndTime() == null) {
            return false;
        }

        long secondsUntilEnd = Duration.between(Instant.now(), auction.getEndTime()).getSeconds();
        if (secondsUntilEnd > 0 && secondsUntilEnd <= LAST_MINUTE_EXTENSION_THRESHOLD_SECONDS) {
            auction.setEndTime(auction.getEndTime().plusSeconds(LAST_MINUTE_EXTENSION_SECONDS));
            auction.setTimeExtended(true);
            log.info("Auction {} extended by {} seconds due to last-minute bid.", auction.getId(), LAST_MINUTE_EXTENSION_SECONDS);
            return true;
        }
        return false;
    }

    private void broadcastNewBid(AuctionRoom auction, Bid bid) {
        BidEvent bidEvent = new BidEvent(
                EventType.NEW_BID,
                auction.getId(),
                bid.getBidder().getId(),
                getMaskedBidderName(bid.getBidder()),
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
                getMaskedBidderName(auction.getHighestBidder()),
                auction.getEndTime()
        );
        String topic = "/topic/auction/" + auction.getId();
        messagingTemplate.convertAndSend(topic, updateEvent);
        log.debug("Broadcast to {}: {}", topic, updateEvent);
    }

    private String getMaskedBidderName(User user) {
        return profileRepository.findById(user.getId())
                .map(profile -> profile.getFullName())
                .filter(fullName -> fullName != null && !fullName.isBlank())
                .map(PrivacyMaskingUtil::maskDisplayName)
                .orElseGet(() -> PrivacyMaskingUtil.maskDisplayName(user.getUsername()));
    }
}
