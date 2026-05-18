package com.application.auction.controller;

import com.application.auction.dto.request.AuctionRoomJoinRequest;
import com.application.auction.dto.request.AuctionRoomRequest;
import com.application.auction.dto.request.BidRequest;
import com.application.auction.dto.request.WinnerPaymentSubmitRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.AuctionRankingResponse;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.dto.response.AuctionRoomSummaryResponse;
import com.application.auction.dto.response.BidResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.service.AuctionRoomService;
import com.application.auction.service.AuctionRoomAccessService;
import com.application.auction.service.BidService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/auction-rooms")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionRoomController {

    AuctionRoomService auctionRoomService;
    AuctionRoomAccessService auctionRoomAccessService;
    BidService bidService;

    @PostMapping
    public ApiResponse<ProductResponse> createAuctionRoom(@RequestBody AuctionRoomRequest request) {
        return ApiResponse.<ProductResponse>builder()
                .result(auctionRoomService.createAuctionRoom(request))
                .build();
    }

    @PutMapping("/{roomId}")
    public ApiResponse<ProductResponse> updateAuctionRoom(
            @PathVariable UUID roomId,
            @RequestBody AuctionRoomRequest request
    ) {
        return ApiResponse.<ProductResponse>builder()
                .result(auctionRoomService.updateAuctionRoom(roomId, request))
                .build();
    }

    @PutMapping("/{roomId}/cancel")
    public ApiResponse<ProductResponse> cancelAuctionRoom(@PathVariable UUID roomId) {
        return ApiResponse.<ProductResponse>builder()
                .result(auctionRoomService.cancelAuctionRoom(roomId))
                .build();
    }

    @GetMapping
    public ApiResponse<List<ProductResponse>> getProductsWithAuctionRooms() {
        return ApiResponse.<List<ProductResponse>>builder()
                .result(auctionRoomService.getProductsWithAuctionRooms())
                .build();
    }

    @GetMapping("/winner-payments/me")
    public ApiResponse<List<AuctionRoomSummaryResponse>> getMyWinnerPayments() {
        return ApiResponse.<List<AuctionRoomSummaryResponse>>builder()
                .result(auctionRoomService.getMyWinnerPayments())
                .build();
    }

    @PostMapping("/join")
    public ApiResponse<AuctionRoomAccessResponse> joinAuctionRoom(@RequestBody AuctionRoomJoinRequest request) {
        return ApiResponse.<AuctionRoomAccessResponse>builder()
                .result(auctionRoomAccessService.joinAuctionRoom(request))
                .build();
    }

    @GetMapping("/{roomId}")
    public ApiResponse<AuctionRoomResponse> getAuctionRoom(@PathVariable UUID roomId) {
        return ApiResponse.<AuctionRoomResponse>builder()
                .result(auctionRoomService.getAuctionRoom(roomId))
                .build();
    }

    @GetMapping("/{roomId}/summary")
    public ApiResponse<AuctionRoomSummaryResponse> getAuctionRoomSummary(@PathVariable UUID roomId) {
        return ApiResponse.<AuctionRoomSummaryResponse>builder()
                .result(auctionRoomService.getAuctionRoomSummary(roomId))
                .build();
    }

    @GetMapping("/{roomId}/rankings")
    public ApiResponse<List<AuctionRankingResponse>> getAuctionRankings(@PathVariable UUID roomId) {
        return ApiResponse.<List<AuctionRankingResponse>>builder()
                .result(bidService.getTopRankings(roomId, 5))
                .build();
    }

    @PostMapping("/{roomId}/bids")
    public ApiResponse<BidResponse> placeBid(
            @PathVariable UUID roomId,
            @RequestBody BidRequest request
    ) {
        return ApiResponse.<BidResponse>builder()
                .result(bidService.placeBid(roomId, request))
                .build();
    }

    @PutMapping("/{roomId}/winner-payment")
    public ApiResponse<AuctionRoomSummaryResponse> submitWinnerPayment(
            @PathVariable UUID roomId,
            @RequestBody(required = false) WinnerPaymentSubmitRequest request
    ) {
        return ApiResponse.<AuctionRoomSummaryResponse>builder()
                .result(auctionRoomService.submitWinnerPayment(roomId, request))
                .build();
    }

    @PutMapping("/{roomId}/winner-offer/accept")
    public ApiResponse<AuctionRoomSummaryResponse> acceptWinnerOffer(@PathVariable UUID roomId) {
        return ApiResponse.<AuctionRoomSummaryResponse>builder()
                .result(auctionRoomService.acceptWinnerOffer(roomId))
                .build();
    }
}
