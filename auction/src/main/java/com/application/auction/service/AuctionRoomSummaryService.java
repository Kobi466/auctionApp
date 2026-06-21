package com.application.auction.service;

import com.application.auction.dto.response.AuctionParticipantResponse;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.dto.response.AuctionRoomSummaryResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.Bid;
import com.application.auction.entity.Product;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.mapper.ProductMapper;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionRoomSummaryService {

    AuctionRoomRepository auctionRoomRepository;
    AuctionDepositRepository auctionDepositRepository;
    ProductRepository productRepository;
    UserRepository userRepository;
    BidRepository bidRepository;
    BidService bidService;
    AuctionRoomParticipantService participantService;
    ProductMapper productMapper;
    AuctionRoomMapper auctionRoomMapper;
    AuctionFinalizationService finalizationService;

    public List<ProductResponse> getProductsWithAuctionRooms() {
        finalizationService.finalizeEndedAuctions();
        return auctionRoomRepository.findAll().stream()
                .map(room -> {
                    applyCurrentStatus(room);
                    Product product = getProduct(room.getProduct().getId());
                    return toProductResponse(product, room);
                })
                .toList();
    }

    public AuctionRoomResponse getAuctionRoom(UUID roomId) {
        finalizationService.finalizeEndedAuctions();
        AuctionRoom room = getRoom(roomId);
        applyCurrentStatus(room);
        return auctionRoomMapper.toAuctionRoomResponse(room);
    }

    public AuctionRoomSummaryResponse getAuctionRoomSummary(UUID roomId) {
        finalizationService.finalizeEndedAuctions();
        AuctionRoom room = getRoom(roomId);
        applyCurrentStatus(room);
        return buildSummary(room);
    }

    public List<AuctionRoomSummaryResponse> getMyWinnerPayments() {
        finalizationService.finalizeEndedAuctions();
        User currentUser = getCurrentUser();
        return auctionRoomRepository.findAll().stream()
                .filter(room -> room.getStatus() == AuctionRoomStatus.WAITING_WINNER_PAYMENT
                        || room.getStatus() == AuctionRoomStatus.SOLD)
                .filter(room -> resolveCurrentWinnerBid(room)
                        .map(bid -> bid.getBidder().getId().equals(currentUser.getId()))
                        .orElse(false))
                .map(this::buildSummary)
                .toList();
    }

    public AuctionRoomSummaryResponse buildSummary(AuctionRoom room) {
        Product product = getProduct(room.getProduct().getId());
        ProductResponse productResponse = toProductResponse(product, room);
        UUID roomId = room.getId();
        List<AuctionParticipantResponse> participants = participantService.getApprovedParticipants(roomId);

        return AuctionRoomSummaryResponse.builder()
                .product(productResponse)
                .currentPrice(bidService.getCurrentPrice(room))
                .bidCount(bidService.countBid(roomId))
                .watcherCount(participants.size())
                .participants(participants)
                .bids(bidService.getBidHistory(roomId))
                .currentWinnerRank(room.getCurrentWinnerRank())
                .winnerPaymentStatus(room.getWinnerPaymentStatus() == null ? null : room.getWinnerPaymentStatus().name())
                .winnerPaymentMethod(room.getWinnerPaymentMethod())
                .winnerShippingAddress(room.getWinnerShippingAddress())
                .winnerPaymentAmount(resolveWinnerPaymentAmount(room))
                .winnerPaymentReceiptUrl(room.getWinnerPaymentReceiptUrl())
                .winnerPaymentUserNote(room.getWinnerPaymentUserNote())
                .winnerPaymentRejectedCount(room.getWinnerPaymentRejectedCount())
                .winnerPaymentSubmittedAt(room.getWinnerPaymentSubmittedAt())
                .currentUserWinnerPaymentEligible(isCurrentUserWinnerPaymentEligible(room))
                .build();
    }

    public ProductResponse toProductResponse(Product product, AuctionRoom room) {
        ProductResponse response = productMapper.toProductResponse(product);
        response.setAuctionRoom(auctionRoomMapper.toAuctionRoomResponse(room));
        return response;
    }

    public Bid getBidByRank(UUID roomId, int rank) {
        List<Bid> ranking = getUniqueBidderRanking(roomId, 5);
        if (rank < 1 || ranking.size() < rank) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return ranking.get(rank - 1);
    }

    private java.util.Optional<Bid> resolveCurrentWinnerBid(AuctionRoom room) {
        if (room.getCurrentWinnerRank() == null) return java.util.Optional.empty();
        try {
            return java.util.Optional.of(getBidByRank(room.getId(), room.getCurrentWinnerRank()));
        } catch (AppException exception) {
            return java.util.Optional.empty();
        }
    }

    private BigDecimal resolveWinnerPaymentAmount(AuctionRoom room) {
        return resolveCurrentWinnerBid(room)
                .map(bid -> {
                    BigDecimal winningAmount = bid.getAmount();
                    BigDecimal approvedDepositAmount = auctionDepositRepository
                            .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), bid.getBidder().getId())
                            .filter(deposit -> deposit.getStatus() == AuctionDepositStatus.APPROVED
                                    || deposit.getStatus() == AuctionDepositStatus.SETTLED)
                            .map(AuctionDeposit::getRequiredAmount)
                            .orElse(BigDecimal.ZERO);
                    BigDecimal remainingAmount = winningAmount.subtract(approvedDepositAmount);
                    return remainingAmount.compareTo(BigDecimal.ZERO) < 0
                            ? BigDecimal.ZERO
                            : remainingAmount;
                })
                .orElse(null);
    }

    private List<Bid> getUniqueBidderRanking(UUID roomId, int limit) {
        Map<UUID, Bid> bestBidByUser = new LinkedHashMap<>();
        bidRepository.findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(roomId)
                .forEach(bid -> bestBidByUser.putIfAbsent(bid.getBidder().getId(), bid));
        return bestBidByUser.values().stream().limit(limit).toList();
    }

    private boolean isCurrentUserWinnerPaymentEligible(AuctionRoom room) {
        if (room.getCurrentWinnerRank() == null
                || room.getStatus() != AuctionRoomStatus.WAITING_WINNER_PAYMENT) {
            return false;
        }
        User currentUser = getCurrentUser();
        return resolveCurrentWinnerBid(room)
                .map(bid -> bid.getBidder().getId().equals(currentUser.getId()))
                .orElse(false);
    }

    private void applyCurrentStatus(AuctionRoom room) {
        if (room.getStatus() == AuctionRoomStatus.CANCELLED
                || room.getStatus() == AuctionRoomStatus.WAITING_WINNER_PAYMENT
                || room.getStatus() == AuctionRoomStatus.SOLD
                || room.getStatus() == AuctionRoomStatus.FAILED) {
            return;
        }
        room.setStatus(resolveStatus(room.getStartTime(), room.getEndTime()));
    }

    private AuctionRoomStatus resolveStatus(Instant startTime, Instant endTime) {
        Instant now = Instant.now();
        if (now.isBefore(startTime)) return AuctionRoomStatus.SCHEDULED;
        if (now.isAfter(endTime)) return AuctionRoomStatus.CLOSED;
        return AuctionRoomStatus.LIVE;
    }

    private AuctionRoom getRoom(UUID roomId) {
        return auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
    }

    private Product getProduct(UUID productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
}
