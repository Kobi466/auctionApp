package com.application.auction.dto.response;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AuctionPaymentConfigResponse {
    Long id;
    String bankName;
    String accountNumber;
    String accountHolderName;
    String qrImageUrl;
    String branchName;
    String transferNotePrefix;
    boolean active;
    Instant createdAt;
    Instant updatedAt;
}
