package com.application.auction.dto.request;

import com.application.auction.enums.AuctionDepositStatus;
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
public class AuctionDepositReviewRequest {
    AuctionDepositStatus status;
    String adminNote;
}
