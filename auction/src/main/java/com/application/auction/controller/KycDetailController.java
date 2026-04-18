package com.application.auction.controller;

import com.application.auction.dto.request.KycDetailRequest;
import com.application.auction.dto.request.KycReviewRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.KycDetailResponse;
import com.application.auction.service.KycDetailService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/kyc-details")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class KycDetailController {

    KycDetailService kycDetailService;

    @GetMapping("/me")
    public ApiResponse<KycDetailResponse> getMyKycDetail() {
        return ApiResponse.<KycDetailResponse>builder()
                .result(kycDetailService.getMyKycDetail())
                .build();
    }

    @PostMapping("/me")
    public ApiResponse<KycDetailResponse> submitMyKyc(@RequestBody KycDetailRequest request) {
        return ApiResponse.<KycDetailResponse>builder()
                .result(kycDetailService.submitMyKyc(request))
                .build();
    }


    //admin duyệt
    @PutMapping("/{kycDetailId}/status")
    public ApiResponse<KycDetailResponse> reviewKyc(
            @PathVariable UUID kycDetailId,
            @RequestBody KycReviewRequest request
    ) {
        return ApiResponse.<KycDetailResponse>builder()
                .result(kycDetailService.reviewKyc(kycDetailId, request))
                .build();
    }
}
