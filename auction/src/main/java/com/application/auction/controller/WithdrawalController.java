package com.application.auction.controller;

import com.application.auction.dto.request.WithdrawalCreateRequest;
import com.application.auction.dto.request.WithdrawalReviewRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.WithdrawalResponse;
import com.application.auction.service.WithdrawalService;
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
@RequestMapping("/withdrawals")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class WithdrawalController {
    WithdrawalService withdrawalService;

    @GetMapping("/me")
    public ApiResponse<List<WithdrawalResponse>> getMyWithdrawals() {
        return ApiResponse.<List<WithdrawalResponse>>builder()
                .result(withdrawalService.getMyWithdrawals())
                .build();
    }

    @PostMapping
    public ApiResponse<WithdrawalResponse> createWithdrawal(@RequestBody WithdrawalCreateRequest request) {
        return ApiResponse.<WithdrawalResponse>builder()
                .result(withdrawalService.createWithdrawal(request))
                .build();
    }

    @GetMapping
    public ApiResponse<List<WithdrawalResponse>> getWithdrawals(
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.<List<WithdrawalResponse>>builder()
                .result(withdrawalService.getWithdrawals(status))
                .build();
    }

    @PutMapping("/{withdrawalId}/review")
    public ApiResponse<WithdrawalResponse> reviewWithdrawal(
            @PathVariable UUID withdrawalId,
            @RequestBody WithdrawalReviewRequest request
    ) {
        return ApiResponse.<WithdrawalResponse>builder()
                .result(withdrawalService.reviewWithdrawal(withdrawalId, request))
                .build();
    }
}
