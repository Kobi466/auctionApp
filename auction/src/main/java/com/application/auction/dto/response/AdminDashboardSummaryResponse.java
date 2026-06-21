package com.application.auction.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AdminDashboardSummaryResponse {
    long totalUsers;
    long totalProducts;
    long totalAuctionRooms;
    long totalPendingKyc;
    long totalVerifiedKyc;
    long totalRejectedKyc;
    BigDecimal totalWinningAmount;
    BigDecimal totalNetWinningAmount;
    BigDecimal totalOriginalCost;
    BigDecimal totalExpectedRevenue;
    BigDecimal totalConfirmedRevenue;
    BigDecimal totalPendingReceivable;
    BigDecimal totalHeldDeposit;
    BigDecimal totalForfeitedDeposit;
    BigDecimal totalRefundedDeposit;
    BigDecimal totalSettledDeposit;
    BigDecimal estimatedNetProfit;
    List<FinanceRankingItem> financeRankings;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class FinanceRankingItem {
        String roomId;
        String productName;
        String winnerName;
        BigDecimal winningAmount;
        BigDecimal netWinningAmount;
        BigDecimal originalCost;
        BigDecimal estimatedProfit;
        BigDecimal remainingPayment;
        BigDecimal depositAmount;
        String depositStatus;
        String paymentStatus;
        String paymentMethod;
        Instant endTime;
    }
}
