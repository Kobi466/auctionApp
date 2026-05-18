package com.application.auction.service;

import com.application.auction.dto.request.AdminWinnerPaymentReviewRequest;
import com.application.auction.dto.response.AdminWinnerCandidateResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.Notification;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.ProductStatus;
import com.application.auction.enums.WinnerPaymentStatus;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.NotificationRepository;
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
public class AdminWinnerPaymentService {
    static final int MAX_REJECTIONS = 3;

    AuctionRoomRepository auctionRoomRepository;
    ProductRepository productRepository;
    AuctionDepositRepository auctionDepositRepository;
    NotificationRepository notificationRepository;
    AdminWinnerQueryService winnerQueryService;
    AdminWinnerFlowService winnerFlowService;

    public List<AdminWinnerCandidateResponse> confirm(UUID roomId, AdminWinnerPaymentReviewRequest request) {
        AuctionRoom room = getReviewableRoom(roomId);
        room.setWinnerPaymentStatus(WinnerPaymentStatus.PAID);
        room.setWinnerPaymentAdminNote(normalize(request == null ? null : request.getAdminNote()));
        room.setWinnerPaymentConfirmedAt(Instant.now());
        room.setStatus(AuctionRoomStatus.SOLD);
        room.getProduct().setStatus(ProductStatus.SOLD);
        auctionRoomRepository.save(room);
        productRepository.save(room.getProduct());

        Bid winnerBid = winnerQueryService.getBidByRank(roomId, room.getCurrentWinnerRank());
        settleWinnerDeposit(roomId, winnerBid);
        refundLosingDeposits(roomId);
        createNotification(
                winnerBid.getBidder().getId(),
                "Thanh toan dau gia da duoc xac nhan",
                "Admin da xac nhan da nhan tien thanh toan san pham \""
                        + room.getProduct().getName() + "\". Don hang dang cho admin gui do.",
                "AUCTION_WINNER_PAYMENT_CONFIRMED"
        );
        return winnerQueryService.mapRanking(room);
    }

    public List<AdminWinnerCandidateResponse> reject(UUID roomId, AdminWinnerPaymentReviewRequest request) {
        AuctionRoom room = getReviewableRoom(roomId);
        int rejectedCount = room.getWinnerPaymentRejectedCount() == null
                ? 1
                : room.getWinnerPaymentRejectedCount() + 1;
        room.setWinnerPaymentRejectedCount(rejectedCount);
        room.setWinnerPaymentAdminNote(normalize(request == null ? null : request.getAdminNote()));

        Bid bid = winnerQueryService.getBidByRank(roomId, room.getCurrentWinnerRank());
        if (rejectedCount < MAX_REJECTIONS) {
            rejectForRetry(room, bid, rejectedCount);
        } else {
            rejectFinally(room, bid);
        }
        return winnerQueryService.mapRanking(room);
    }

    private AuctionRoom getReviewableRoom(UUID roomId) {
        AuctionRoom room = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        if (!canReviewWinnerPayment(room)
                || room.getWinnerPaymentStatus() != WinnerPaymentStatus.PAYMENT_SUBMITTED
                || room.getCurrentWinnerRank() == null) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return room;
    }

    private void rejectForRetry(AuctionRoom room, Bid bid, int rejectedCount) {
        room.setWinnerPaymentStatus(WinnerPaymentStatus.PAYMENT_REJECTED);
        auctionRoomRepository.save(room);
        createNotification(
                bid.getBidder().getId(),
                "Bien lai thanh toan chua hop le",
                "Admin chua xac nhan duoc bien lai thanh toan san pham \""
                        + room.getProduct().getName() + "\". Vui long kiem tra va gui lai. Lan thu "
                        + rejectedCount + "/" + MAX_REJECTIONS + ".",
                "AUCTION_WINNER_PAYMENT_REJECTED"
        );
    }

    private void rejectFinally(AuctionRoom room, Bid bid) {
        auctionDepositRepository.findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(
                room.getId(),
                bid.getBidder().getId()
        ).ifPresent(deposit -> {
            if (deposit.getStatus() == AuctionDepositStatus.APPROVED) {
                deposit.setStatus(AuctionDepositStatus.FORFEITED);
                deposit.setAdminNote("Bien lai thanh toan bi tu choi "
                        + MAX_REJECTIONS + " lan, tien coc bi mat.");
                auctionDepositRepository.save(deposit);
            }
        });
        createNotification(
                bid.getBidder().getId(),
                "Giao dich dau gia da bi huy",
                "Bien lai thanh toan san pham \"" + room.getProduct().getName()
                        + "\" da bi tu choi " + MAX_REJECTIONS
                        + " lan. Quyen mua se duoc chuyen cho nguoi xep hang tiep theo.",
                "AUCTION_WINNER_PAYMENT_FAILED"
        );
        winnerFlowService.advanceOfferAfterSkippedRank(room, room.getCurrentWinnerRank());
    }

    private void refundLosingDeposits(UUID roomId) {
        List<Bid> ranking = winnerQueryService.getUniqueBidderRanking(roomId, 5);
        for (int index = 1; index < ranking.size(); index++) {
            winnerFlowService.refundDeposit(
                    roomId,
                    ranking.get(index),
                    "Hoan coc vi san pham da duoc thanh toan thanh cong."
            );
        }
    }

    private void settleWinnerDeposit(UUID roomId, Bid bid) {
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(roomId, bid.getBidder().getId())
                .orElse(null);
        if (deposit != null && deposit.getStatus() == AuctionDepositStatus.APPROVED) {
            deposit.setStatus(AuctionDepositStatus.SETTLED);
            deposit.setAdminNote("Tien coc da duoc tat toan sau khi nguoi thang thanh toan thanh cong.");
            auctionDepositRepository.save(deposit);
        }
    }

    private boolean canReviewWinnerPayment(AuctionRoom room) {
        return room.getStatus() == AuctionRoomStatus.WAITING_WINNER_PAYMENT
                || room.getStatus() == AuctionRoomStatus.CLOSED;
    }

    private Notification createNotification(UUID userId, String title, String message, String type) {
        if (title == null || message == null) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return notificationRepository.save(Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type(type == null ? "ADMIN_MESSAGE" : type)
                .build());
    }

    private String normalize(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
