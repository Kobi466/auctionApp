package com.application.auction.service;

import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.enums.WinnerPaymentStatus;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.experimental.FieldDefaults;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class AuctionFinalizationService {

    AuctionRoomRepository auctionRoomRepository;
    BidRepository bidRepository;
    AuctionWinnerNotificationService winnerNotificationService;
    TransactionTemplate transactionTemplate;

    @Scheduled(initialDelay = 5000, fixedDelay = 5000)
    public void finalizeEndedAuctions() {
        auctionRoomRepository.findEndedRoomIdsPendingFinalization(Instant.now())
                .forEach(this::finalizeRoomSafely);
    }

    public void finalizeRoom(UUID roomId) {
        AuctionRoom room = auctionRoomRepository.findByIdForUpdate(roomId)
                .orElse(null);
        if (room == null || room.isWinnerNotified() || room.getStatus() == AuctionRoomStatus.CANCELLED) {
            return;
        }
        if (room.getEndTime() == null || Instant.now().isBefore(room.getEndTime())) {
            return;
        }

        room.setStatus(AuctionRoomStatus.CLOSED);
        Bid winningBid = bidRepository.findTopByAuctionRoomIdOrderByAmountDescCreatedAtAsc(room.getId())
                .orElse(null);
        if (winningBid != null) {
            room.setHighestBidder(winningBid.getBidder());
            room.setCurrentPrice(winningBid.getAmount());
            room.setStatus(AuctionRoomStatus.WAITING_WINNER_PAYMENT);
            room.setCurrentWinnerRank(1);
            room.setWinnerPaymentStatus(WinnerPaymentStatus.WAITING_PAYMENT);
            room.setWinnerPaymentRejectedCount(0);
            winnerNotificationService.notifyWinner(room);
        }
        room.setWinnerNotified(true);
    }

    private void finalizeRoomSafely(UUID roomId) {
        try {
            transactionTemplate.executeWithoutResult(status -> finalizeRoom(roomId));
        } catch (Exception exception) {
            log.error("Could not finalize auction room {}", roomId, exception);
        }
    }
}
