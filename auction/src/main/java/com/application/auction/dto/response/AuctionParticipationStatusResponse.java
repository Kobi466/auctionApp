package com.application.auction.dto.response;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AuctionParticipationStatusResponse {
    boolean kycVerified;
    ProductResponse product;
    String auctionRules;
    boolean agreedToRules;
    AuctionDepositResponse deposit;
    AuctionPaymentConfigResponse paymentConfig;
    boolean roomAccessGranted;
}
