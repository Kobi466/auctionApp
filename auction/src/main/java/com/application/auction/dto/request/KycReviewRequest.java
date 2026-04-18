package com.application.auction.dto.request;

import com.application.auction.enums.KycStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class KycReviewRequest {
    KycStatus status;
    String rejectedReason;
}
