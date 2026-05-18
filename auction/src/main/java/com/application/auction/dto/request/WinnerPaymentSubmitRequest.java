package com.application.auction.dto.request;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class WinnerPaymentSubmitRequest {
    String receiptUrl;
    String userNote;
}

