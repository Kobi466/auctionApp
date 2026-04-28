package com.application.auction.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AdminDashboardSummaryResponse {
    long totalUsers;
    long totalPendingKyc;
    long totalVerifiedKyc;
    long totalRejectedKyc;
}
