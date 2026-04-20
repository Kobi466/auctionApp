package com.application.auction.controller;

import com.application.auction.dto.request.AuctionPaymentConfigRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.service.AuctionPaymentConfigService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auction-payment-config")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionPaymentConfigController {

    AuctionPaymentConfigService auctionPaymentConfigService;

    @PutMapping
    public ApiResponse<AuctionPaymentConfigResponse> upsert(@RequestBody AuctionPaymentConfigRequest request) {
        return ApiResponse.<AuctionPaymentConfigResponse>builder()
                .result(auctionPaymentConfigService.upsert(request))
                .build();
    }

    @GetMapping
    public ApiResponse<AuctionPaymentConfigResponse> getActiveConfig() {
        return ApiResponse.<AuctionPaymentConfigResponse>builder()
                .result(auctionPaymentConfigService.getActive())
                .build();
    }
}
