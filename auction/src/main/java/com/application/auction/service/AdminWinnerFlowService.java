package com.application.auction.service;

import com.application.auction.dto.request.AdminWinnerRankActionRequest;
import com.application.auction.dto.response.AdminWinnerCandidateResponse;
import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.ProductStatus;
import com.application.auction.enums.WinnerPaymentStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.NotificationMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminWinnerFlowService {

    AuctionRoomRepository auctionRoomRepository;
    ProductRepository productRepository;
    AuctionDepositRepository auctionDepositRepository;
    NotificationMapper notificationMapper;
    AuctionWinnerNotificationService winnerNotificationService;
    AdminWinnerQueryService winnerQueryService;

    public NotificationResponse sendOffer(UUID roomId, AdminWinnerRankActionRequest request) {
        AuctionRoom room = getRoom(roomId);
        validatePostAuction(room);
        int rank = validateRank(request);
        validateOfferRank(room, rank);
        Bid bid = winnerQueryService.getBidByRank(roomId, rank);

        if (room.getCurrentWinnerRank() == null || room.getWinnerPaymentStatus() == null) {
            startWinnerOffer(room, rank);
        }

        return notificationMapper.toNotificationResponse(
                winnerNotificationService.sendOfferToCandidate(room, bid, rank, shouldSendEmail(request))
        );
    }

    public NotificationResponse forfeit(UUID roomId, AdminWinnerRankActionRequest request) {
        AuctionRoom room = getRoom(roomId);
        validatePostAuction(room);
        int rank = validateRank(request);
        validateOfferRank(room, rank);
        Bid bid = winnerQueryService.getBidByRank(roomId, rank);

        auctionDepositRepository.findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(roomId, bid.getBidder().getId())
                .ifPresent(deposit -> forfeitDeposit(deposit, rank));

        advanceOfferAfterSkippedRank(room, rank);
        return notificationMapper.toNotificationResponse(
                winnerNotificationService.notifyForfeited(room, bid, rank, shouldSendEmail(request))
        );
    }

    public List<AdminWinnerCandidateResponse> refundRank(UUID roomId, AdminWinnerRankActionRequest request) {
        AuctionRoom room = getRoom(roomId);
        validatePostAuction(room);
        int rank = validateRank(request);
        if (rank == 1) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }

        Bid bid = winnerQueryService.getBidByRank(roomId, rank);
        refundDeposit(roomId, bid, "Hoan coc cho nguoi xep hang " + rank + " khong nhan san pham.");
        if (room.getCurrentWinnerRank() != null && room.getCurrentWinnerRank() == rank) {
            advanceOfferAfterSkippedRank(room, rank);
        }
        return winnerQueryService.mapRanking(room);
    }

    public List<AdminWinnerCandidateResponse> refundLosingDeposits(UUID roomId) {
        AuctionRoom room = getRoom(roomId);
        validatePostAuction(room);
        List<Bid> ranking = winnerQueryService.getUniqueBidderRanking(roomId, 5);
        for (int index = 1; index < ranking.size(); index++) {
            refundDeposit(roomId, ranking.get(index), "Hoan coc sau khi phong dau gia ket thuc.");
        }
        return winnerQueryService.mapRanking(room);
    }

    public void advanceOfferAfterSkippedRank(AuctionRoom room, int skippedRank) {
        List<Bid> ranking = winnerQueryService.getUniqueBidderRanking(room.getId(), 5);
        if (skippedRank >= 5 || ranking.size() <= skippedRank) {
            failAuction(room);
            return;
        }

        int nextRank = skippedRank + 1;
        Bid nextBid = winnerQueryService.getBidByRank(room.getId(), nextRank);
        startWinnerOffer(room, nextRank);
        winnerNotificationService.sendOfferToCandidate(room, nextBid, nextRank, true);
    }

    public void refundDeposit(UUID roomId, Bid bid, String note) {
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(roomId, bid.getBidder().getId())
                .orElse(null);
        if (deposit != null && deposit.getStatus() == AuctionDepositStatus.APPROVED) {
            deposit.setStatus(AuctionDepositStatus.REFUNDED);
            deposit.setAdminNote(note);
            auctionDepositRepository.save(deposit);
        }
    }

    public void validatePostAuction(AuctionRoom room) {
        applyClosedStatusIfEnded(room);
        if (room.getStatus() != AuctionRoomStatus.CLOSED
                && room.getStatus() != AuctionRoomStatus.WAITING_WINNER_PAYMENT) {
            throw new AppException(ErrorCode.AUCTION_ROOM_NOT_ENDED);
        }
    }

    private void startWinnerOffer(AuctionRoom room, int rank) {
        room.setStatus(AuctionRoomStatus.WAITING_WINNER_PAYMENT);
        room.setCurrentWinnerRank(rank);
        room.setWinnerPaymentStatus(rank == 1
                ? WinnerPaymentStatus.WAITING_PAYMENT
                : WinnerPaymentStatus.WAITING_ACCEPTANCE);
        room.setWinnerPaymentReceiptUrl(null);
        room.setWinnerPaymentUserNote(null);
        room.setWinnerPaymentAdminNote(null);
        room.setWinnerPaymentRejectedCount(0);
        room.setWinnerPaymentSubmittedAt(null);
        room.setWinnerPaymentConfirmedAt(null);
        auctionRoomRepository.save(room);
    }

    private void validateOfferRank(AuctionRoom room, int rank) {
        if (room.getCurrentWinnerRank() == null && rank == 1) return;
        if (room.getCurrentWinnerRank() == null || room.getCurrentWinnerRank() != rank) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
    }

    private void applyClosedStatusIfEnded(AuctionRoom room) {
        if (room.getStatus() == AuctionRoomStatus.CANCELLED
                || room.getStatus() == AuctionRoomStatus.CLOSED
                || room.getStatus() == AuctionRoomStatus.WAITING_WINNER_PAYMENT
                || room.getStatus() == AuctionRoomStatus.SOLD
                || room.getStatus() == AuctionRoomStatus.FAILED) {
            return;
        }
        if (room.getEndTime() != null && !Instant.now().isBefore(room.getEndTime())) {
            room.setStatus(AuctionRoomStatus.CLOSED);
        }
    }

    private void failAuction(AuctionRoom room) {
        room.setStatus(AuctionRoomStatus.FAILED);
        room.setWinnerPaymentStatus(WinnerPaymentStatus.FAILED);
        room.setCurrentWinnerRank(null);
        room.getProduct().setStatus(ProductStatus.AUCTION_FAILED);
        auctionRoomRepository.save(room);
        productRepository.save(room.getProduct());
    }

    private void forfeitDeposit(AuctionDeposit deposit, int rank) {
        deposit.setStatus(AuctionDepositStatus.FORFEITED);
        deposit.setAdminNote("Nguoi xep hang " + rank + " khong nhan san pham, tien coc bi mat.");
        auctionDepositRepository.save(deposit);
    }

    private AuctionRoom getRoom(UUID roomId) {
        return auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
    }

    private int validateRank(AdminWinnerRankActionRequest request) {
        if (request == null || request.getRank() == null || request.getRank() < 1 || request.getRank() > 5) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return request.getRank();
    }

    private boolean shouldSendEmail(AdminWinnerRankActionRequest request) {
        return request != null && Boolean.TRUE.equals(request.getSendEmail());
    }
}
