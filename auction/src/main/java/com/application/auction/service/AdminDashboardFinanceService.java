package com.application.auction.service;

import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminDashboardFinanceService {

    AuctionRoomRepository auctionRoomRepository;
    AuctionDepositRepository auctionDepositRepository;
    AdminWinnerQueryService winnerQueryService;

    public AdminDashboardSummaryResponse enrich(AdminDashboardSummaryResponse summary) {
        List<AuctionRoom> rooms = auctionRoomRepository.findAll();
        List<AuctionDeposit> deposits = auctionDepositRepository.findAll();

        BigDecimal totalWinningAmount = BigDecimal.ZERO;
        BigDecimal totalNetWinningAmount = BigDecimal.ZERO;
        BigDecimal totalOriginalCost = BigDecimal.ZERO;
        BigDecimal totalPendingReceivable = BigDecimal.ZERO;

        for (AuctionRoom room : rooms) {
            BigDecimal winningAmount = resolveWinningAmount(room);
            BigDecimal originalCost = resolveOriginalCost(room);
            BigDecimal netWinningAmount = resolveNetWinningAmount(room, winningAmount);
            totalWinningAmount = totalWinningAmount.add(winningAmount);
            if (winningAmount.compareTo(BigDecimal.ZERO) > 0) {
                totalNetWinningAmount = totalNetWinningAmount.add(netWinningAmount);
                totalOriginalCost = totalOriginalCost.add(originalCost);
            }
            if (room.getStatus() != AuctionRoomStatus.SOLD) {
                totalPendingReceivable = totalPendingReceivable.add(resolveRemainingPayment(room, winningAmount));
            }
        }

        BigDecimal heldDeposit = sumDeposits(deposits, AuctionDepositStatus.APPROVED);
        BigDecimal forfeitedDeposit = sumDeposits(deposits, AuctionDepositStatus.FORFEITED);
        BigDecimal refundedDeposit = sumDeposits(deposits, AuctionDepositStatus.REFUNDED);
        BigDecimal settledDeposit = sumDeposits(deposits, AuctionDepositStatus.SETTLED);
        BigDecimal expectedRevenue = totalNetWinningAmount;
        BigDecimal confirmedRevenue = rooms.stream()
                .filter(room -> room.getStatus() == AuctionRoomStatus.SOLD)
                .map(room -> resolveNetWinningAmount(room, resolveWinningAmount(room)))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        summary.setTotalWinningAmount(totalWinningAmount);
        summary.setTotalNetWinningAmount(totalNetWinningAmount);
        summary.setTotalOriginalCost(totalOriginalCost);
        summary.setTotalExpectedRevenue(expectedRevenue);
        summary.setTotalConfirmedRevenue(confirmedRevenue);
        summary.setTotalPendingReceivable(totalPendingReceivable);
        summary.setTotalHeldDeposit(heldDeposit);
        summary.setTotalForfeitedDeposit(forfeitedDeposit);
        summary.setTotalRefundedDeposit(refundedDeposit);
        summary.setTotalSettledDeposit(settledDeposit);
        summary.setEstimatedNetProfit(totalNetWinningAmount.subtract(totalOriginalCost));
        summary.setFinanceRankings(buildRankings(rooms));
        return summary;
    }

    private List<AdminDashboardSummaryResponse.FinanceRankingItem> buildRankings(List<AuctionRoom> rooms) {
        return rooms.stream()
                .map(this::toRankingItem)
                .filter(item -> item.getWinningAmount().compareTo(BigDecimal.ZERO) > 0)
                .sorted(Comparator.comparing(AdminDashboardSummaryResponse.FinanceRankingItem::getWinningAmount).reversed())
                .limit(5)
                .toList();
    }

    private AdminDashboardSummaryResponse.FinanceRankingItem toRankingItem(AuctionRoom room) {
        BigDecimal winningAmount = resolveWinningAmount(room);
        BigDecimal originalCost = resolveOriginalCost(room);
        BigDecimal netWinningAmount = resolveNetWinningAmount(room, winningAmount);
        Bid winnerBid = resolveWinnerBid(room);
        AuctionDeposit deposit = winnerBid == null
                ? null
                : auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), winnerBid.getBidder().getId())
                .orElse(null);

        return AdminDashboardSummaryResponse.FinanceRankingItem.builder()
                .roomId(room.getId().toString())
                .productName(room.getProduct() == null ? "" : room.getProduct().getName())
                .winnerName(winnerBid == null ? "" : resolveWinnerName(winnerBid))
                .winningAmount(winningAmount)
                .netWinningAmount(netWinningAmount)
                .originalCost(originalCost)
                .estimatedProfit(netWinningAmount.subtract(originalCost))
                .remainingPayment(resolveRemainingPayment(room, winningAmount))
                .depositAmount(deposit == null ? BigDecimal.ZERO : deposit.getRequiredAmount())
                .depositStatus(deposit == null ? null : deposit.getStatus().name())
                .paymentStatus(room.getWinnerPaymentStatus() == null ? null : room.getWinnerPaymentStatus().name())
                .paymentMethod(room.getWinnerPaymentMethod())
                .endTime(room.getEndTime())
                .build();
    }

    private BigDecimal resolveWinningAmount(AuctionRoom room) {
        Bid bid = resolveWinnerBid(room);
        return bid == null || bid.getAmount() == null ? BigDecimal.ZERO : bid.getAmount();
    }

    private Bid resolveWinnerBid(AuctionRoom room) {
        if (room.getCurrentWinnerRank() != null) {
            try {
                return winnerQueryService.getBidByRank(room.getId(), room.getCurrentWinnerRank());
            } catch (RuntimeException ignored) {
                return null;
            }
        }
        if (room.getStatus() == AuctionRoomStatus.SOLD && room.getHighestBidder() != null) {
            try {
                return winnerQueryService.getBidByRank(room.getId(), 1);
            } catch (RuntimeException ignored) {
                return null;
            }
        }
        return null;
    }

    private BigDecimal resolveRemainingPayment(AuctionRoom room, BigDecimal winningAmount) {
        Bid bid = resolveWinnerBid(room);
        if (bid == null) return BigDecimal.ZERO;
        BigDecimal depositAmount = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), bid.getBidder().getId())
                .filter(deposit -> deposit.getStatus() == AuctionDepositStatus.APPROVED
                        || deposit.getStatus() == AuctionDepositStatus.SETTLED)
                .map(AuctionDeposit::getRequiredAmount)
                .orElse(BigDecimal.ZERO);
        BigDecimal remaining = winningAmount.subtract(depositAmount);
        return remaining.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : remaining;
    }

    private BigDecimal resolveNetWinningAmount(AuctionRoom room, BigDecimal winningAmount) {
        BigDecimal depositAmount = resolveWinnerDepositAmount(room);
        BigDecimal net = winningAmount.subtract(depositAmount);
        return net.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : net;
    }

    private BigDecimal resolveWinnerDepositAmount(AuctionRoom room) {
        Bid bid = resolveWinnerBid(room);
        if (bid == null) return BigDecimal.ZERO;
        return auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), bid.getBidder().getId())
                .filter(deposit -> deposit.getStatus() == AuctionDepositStatus.APPROVED
                        || deposit.getStatus() == AuctionDepositStatus.SETTLED)
                .map(AuctionDeposit::getRequiredAmount)
                .orElse(BigDecimal.ZERO);
    }

    private BigDecimal resolveOriginalCost(AuctionRoom room) {
        if (room.getProduct() == null || room.getProduct().getStartingPrice() == null) {
            return BigDecimal.ZERO;
        }
        return room.getProduct().getStartingPrice();
    }

    private BigDecimal sumDeposits(List<AuctionDeposit> deposits, AuctionDepositStatus status) {
        return deposits.stream()
                .filter(deposit -> deposit.getStatus() == status)
                .map(AuctionDeposit::getRequiredAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private String resolveWinnerName(Bid bid) {
        String username = bid.getBidder().getUsername();
        if (username != null && !username.trim().isEmpty()) return username.trim();
        return bid.getBidder().getEmail();
    }
}
