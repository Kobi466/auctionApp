package com.application.auction.controller;

import com.application.auction.dto.request.AuctionDepositReviewRequest;
import com.application.auction.dto.request.AuctionDepositSubmitRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.AuctionDepositResponse;
import com.application.auction.dto.response.AuctionParticipationStatusResponse;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.service.AuctionDepositService;
import com.application.auction.service.AuctionParticipationService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/auction-participation")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionParticipationController {

    AuctionParticipationService auctionParticipationService;
    AuctionDepositService auctionDepositService;

    @GetMapping("/products/{productId}")
    public ApiResponse<AuctionParticipationStatusResponse> getStatus(@PathVariable UUID productId) {
        return ApiResponse.<AuctionParticipationStatusResponse>builder()
                .result(auctionParticipationService.getParticipationStatus(productId))
                .build();
    }

    @PostMapping("/products/{productId}/confirm-rules")
    public ApiResponse<AuctionParticipationStatusResponse> confirmRules(@PathVariable UUID productId) {
        return ApiResponse.<AuctionParticipationStatusResponse>builder()
                .result(auctionParticipationService.confirmRules(productId))
                .build();
    }

    @PutMapping("/deposits/{depositId}/submit-payment")
    public ApiResponse<AuctionDepositResponse> submitPayment(
            @PathVariable UUID depositId,
            @RequestBody(required = false) AuctionDepositSubmitRequest request
    ) {
        return ApiResponse.<AuctionDepositResponse>builder()
                .result(auctionDepositService.submitPayment(depositId, request))
                .build();
    }

    @GetMapping("/deposits/me")
    public ApiResponse<List<AuctionDepositResponse>> getMyDeposits() {
        return ApiResponse.<List<AuctionDepositResponse>>builder()
                .result(auctionDepositService.getMyDeposits())
                .build();
    }

    @GetMapping("/deposits")
    public ApiResponse<List<AuctionDepositResponse>> getDeposits(
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.<List<AuctionDepositResponse>>builder()
                .result(auctionDepositService.getDeposits(status))
                .build();
    }

    @PutMapping("/deposits/{depositId}/review")
    public ApiResponse<AuctionDepositResponse> reviewDeposit(
            @PathVariable UUID depositId,
            @RequestBody AuctionDepositReviewRequest request
    ) {
        return ApiResponse.<AuctionDepositResponse>builder()
                .result(auctionDepositService.reviewDeposit(depositId, request))
                .build();
    }

    @GetMapping("/products/{productId}/room-access")
    public ApiResponse<AuctionRoomAccessResponse> getRoomAccess(@PathVariable UUID productId) {
        return ApiResponse.<AuctionRoomAccessResponse>builder()
                .result(auctionParticipationService.getRoomAccess(productId))
                .build();
    }
}
