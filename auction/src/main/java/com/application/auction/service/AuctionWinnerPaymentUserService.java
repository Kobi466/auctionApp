package com.application.auction.service;

import com.application.auction.dto.request.WinnerPaymentSubmitRequest;
import com.application.auction.dto.response.AuctionRoomSummaryResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.WinnerPaymentStatus;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionWinnerPaymentUserService {

    AuctionRoomRepository auctionRoomRepository;
    UserRepository userRepository;
    AuctionRoomSummaryService summaryService;

    public AuctionRoomSummaryResponse acceptWinnerOffer(UUID roomId) {
        User currentUser = getCurrentUser();
        AuctionRoom room = getWaitingWinnerRoom(roomId);
        if (room.getWinnerPaymentStatus() != WinnerPaymentStatus.WAITING_ACCEPTANCE) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        ensureCurrentRankBidder(room, currentUser);

        room.setWinnerPaymentStatus(WinnerPaymentStatus.WAITING_PAYMENT);
        room.setWinnerPaymentMethod(null);
        room.setWinnerShippingAddress(null);
        room.setWinnerPaymentReceiptUrl(null);
        room.setWinnerPaymentUserNote(null);
        room.setWinnerPaymentAdminNote(null);
        room.setWinnerPaymentSubmittedAt(null);
        auctionRoomRepository.save(room);
        return summaryService.getAuctionRoomSummary(roomId);
    }

    public AuctionRoomSummaryResponse submitWinnerPayment(UUID roomId, WinnerPaymentSubmitRequest request) {
        User currentUser = getCurrentUser();
        AuctionRoom room = getWaitingWinnerRoom(roomId);
        ensureCurrentRankBidder(room, currentUser);
        if (room.getWinnerPaymentStatus() != WinnerPaymentStatus.WAITING_PAYMENT
                && room.getWinnerPaymentStatus() != WinnerPaymentStatus.PAYMENT_REJECTED) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }

        String receiptUrl = normalize(request == null ? null : request.getReceiptUrl());
        String userNote = normalize(request == null ? null : request.getUserNote());
        String shippingAddress = normalize(request == null ? null : request.getShippingAddress());
        String paymentMethod = normalize(request == null ? null : request.getPaymentMethod());
        if (paymentMethod == null) {
            paymentMethod = "BANK_TRANSFER";
        }
        paymentMethod = paymentMethod.toUpperCase();
        if (!paymentMethod.equals("BANK_TRANSFER") && !paymentMethod.equals("COD")) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }

        String existingReceiptUrl = normalize(room.getWinnerPaymentReceiptUrl());
        if (paymentMethod.equals("BANK_TRANSFER") && receiptUrl == null && userNote == null && existingReceiptUrl == null) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }

        room.setWinnerPaymentMethod(paymentMethod);
        room.setWinnerShippingAddress(shippingAddress);
        if (paymentMethod.equals("COD")) {
            room.setWinnerPaymentReceiptUrl(null);
            room.setWinnerPaymentUserNote(userNote == null ? "Thanh toan khi nhan hang" : userNote);
        } else {
            room.setWinnerPaymentReceiptUrl(receiptUrl == null ? existingReceiptUrl : receiptUrl);
            room.setWinnerPaymentUserNote(userNote);
        }
        room.setWinnerPaymentSubmittedAt(Instant.now());
        room.setWinnerPaymentStatus(WinnerPaymentStatus.PAYMENT_SUBMITTED);
        auctionRoomRepository.save(room);
        return summaryService.getAuctionRoomSummary(roomId);
    }

    private AuctionRoom getWaitingWinnerRoom(UUID roomId) {
        AuctionRoom room = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        if (room.getStatus() != AuctionRoomStatus.WAITING_WINNER_PAYMENT || room.getCurrentWinnerRank() == null) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return room;
    }

    private void ensureCurrentRankBidder(AuctionRoom room, User currentUser) {
        Bid bid = summaryService.getBidByRank(room.getId(), room.getCurrentWinnerRank());
        if (!bid.getBidder().getId().equals(currentUser.getId())) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
