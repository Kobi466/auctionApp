package com.application.auction.dto.request;

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
public class AuctionPaymentConfigRequest {
    String bankName;
    String accountNumber;
    String accountHolderName;
    String qrImageUrl;
    String branchName;
    String transferNotePrefix;
    Boolean active;
}
