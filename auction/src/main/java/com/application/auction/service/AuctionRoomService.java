package com.application.auction.service;

import com.application.auction.dto.request.AuctionRoomRequest;
import com.application.auction.dto.request.WinnerPaymentSubmitRequest;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.dto.response.AuctionRoomSummaryResponse;
import com.application.auction.dto.response.ProductResponse;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionRoomService {

    AuctionRoomCommandService commandService;
    AuctionRoomSummaryService summaryService;
    AuctionWinnerPaymentUserService winnerPaymentUserService;

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse createAuctionRoom(AuctionRoomRequest request) {
        return commandService.createAuctionRoom(request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse updateAuctionRoom(UUID roomId, AuctionRoomRequest request) {
        return commandService.updateAuctionRoom(roomId, request);
    }

    @Transactional
    public List<ProductResponse> getProductsWithAuctionRooms() {
        return summaryService.getProductsWithAuctionRooms();
    }

    @Transactional
    public AuctionRoomResponse getAuctionRoom(UUID roomId) {
        return summaryService.getAuctionRoom(roomId);
    }

    @Transactional
    public AuctionRoomSummaryResponse getAuctionRoomSummary(UUID roomId) {
        return summaryService.getAuctionRoomSummary(roomId);
    }

    @Transactional
    public List<AuctionRoomSummaryResponse> getMyWinnerPayments() {
        return summaryService.getMyWinnerPayments();
    }

    @Transactional
    public AuctionRoomSummaryResponse acceptWinnerOffer(UUID roomId) {
        return winnerPaymentUserService.acceptWinnerOffer(roomId);
    }

    @Transactional
    public AuctionRoomSummaryResponse submitWinnerPayment(UUID roomId, WinnerPaymentSubmitRequest request) {
        return winnerPaymentUserService.submitWinnerPayment(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse cancelAuctionRoom(UUID roomId) {
        return commandService.cancelAuctionRoom(roomId);
    }
}
