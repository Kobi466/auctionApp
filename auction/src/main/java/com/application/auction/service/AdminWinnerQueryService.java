package com.application.auction.service;

import com.application.auction.dto.response.AdminWinnerCandidateResponse;
import com.application.auction.dto.response.AdminWinnerResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.Product;
import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminWinnerQueryService {

    AuctionRoomRepository auctionRoomRepository;
    BidRepository bidRepository;
    AuctionDepositRepository auctionDepositRepository;
    ProfileRepository profileRepository;
    AuctionFinalizationService auctionFinalizationService;

    public List<AdminWinnerResponse> getWinners(String search, String status) {
        auctionFinalizationService.finalizeEndedAuctions();
        String normalizedSearch = normalize(search);
        String normalizedStatus = normalize(status);

        return auctionRoomRepository.findAll().stream()
                .filter(room -> room.getHighestBidder() != null)
                .filter(this::isWinnerManagementVisible)
                .map(this::mapToAdminWinnerResponse)
                .filter(winner -> matchesSearch(winner, normalizedSearch))
                .filter(winner -> matchesStatus(winner, normalizedStatus))
                .toList();
    }

    public List<AdminWinnerCandidateResponse> getWinnerRanking(UUID roomId) {
        AuctionRoom room = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        return mapRanking(room);
    }

    public List<AdminWinnerCandidateResponse> mapRanking(AuctionRoom room) {
        return mapRanking(room, getUniqueBidderRanking(room.getId(), 5));
    }

    public Bid getBidByRank(UUID roomId, int rank) {
        List<Bid> ranking = getUniqueBidderRanking(roomId, 5);
        if (ranking.size() < rank) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        return ranking.get(rank - 1);
    }

    public List<Bid> getUniqueBidderRanking(UUID roomId, int limit) {
        Map<UUID, Bid> bestBidByUser = new LinkedHashMap<>();
        bidRepository.findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(roomId)
                .forEach(bid -> bestBidByUser.putIfAbsent(bid.getBidder().getId(), bid));
        return bestBidByUser.values().stream().limit(limit).toList();
    }

    private List<AdminWinnerCandidateResponse> mapRanking(AuctionRoom room, List<Bid> ranking) {
        return java.util.stream.IntStream.range(0, ranking.size())
                .mapToObj(index -> mapRankingItem(room, ranking.get(index), index + 1))
                .toList();
    }

    private AdminWinnerCandidateResponse mapRankingItem(AuctionRoom room, Bid bid, int rank) {
        User bidder = bid.getBidder();
        String depositStatus = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(bid.getAuctionRoom().getId(), bidder.getId())
                .map(deposit -> deposit.getStatus().name())
                .orElse(null);
        boolean active = room.getCurrentWinnerRank() != null && room.getCurrentWinnerRank() == rank;

        return AdminWinnerCandidateResponse.builder()
                .rank(rank)
                .userId(bidder.getId())
                .userName(resolveUserName(bidder))
                .userEmail(bidder.getEmail())
                .amount(bid.getAmount())
                .bidTime(bid.getTimestamp())
                .winner(rank == 1)
                .depositStatus(depositStatus)
                .activeOffer(active)
                .winnerPaymentStatus(active && room.getWinnerPaymentStatus() != null
                        ? room.getWinnerPaymentStatus().name() : null)
                .winnerPaymentMethod(active ? room.getWinnerPaymentMethod() : null)
                .winnerShippingAddress(active ? room.getWinnerShippingAddress() : null)
                .winnerPaymentReceiptUrl(active ? room.getWinnerPaymentReceiptUrl() : null)
                .winnerPaymentUserNote(active ? room.getWinnerPaymentUserNote() : null)
                .winnerPaymentAdminNote(active ? room.getWinnerPaymentAdminNote() : null)
                .winnerPaymentRejectedCount(active ? room.getWinnerPaymentRejectedCount() : null)
                .winnerPaymentSubmittedAt(active ? room.getWinnerPaymentSubmittedAt() : null)
                .build();
    }

    private AdminWinnerResponse mapToAdminWinnerResponse(AuctionRoom room) {
        Product product = room.getProduct();
        User winner = room.getHighestBidder();
        String imageUrl = product.getMainImageUrl();
        if (imageUrl == null && product.getImageUrls() != null && !product.getImageUrls().isEmpty()) {
            imageUrl = product.getImageUrls().get(0);
        }

        return AdminWinnerResponse.builder()
                .id(room.getId())
                .productName(product.getName())
                .winnerName(resolveUserName(winner))
                .statusLabel("Won")
                .subStatusLabel(room.getStatus().name())
                .price(room.getCurrentPrice())
                .winningTime(room.getEndTime())
                .imageUrl(imageUrl)
                .status(resolveWinnerListStatus(room))
                .build();
    }

    private String resolveUserName(User user) {
        String name = profileRepository.findById(user.getId())
                .map(Profile::getFullName)
                .map(this::normalize)
                .orElse(null);
        if (name != null) return name;
        name = normalize(user.getUsername());
        return name == null ? user.getEmail() : name;
    }

    private boolean isWinnerManagementVisible(AuctionRoom room) {
        return room.getStatus() == AuctionRoomStatus.CLOSED
                || room.getStatus() == AuctionRoomStatus.WAITING_WINNER_PAYMENT
                || room.getStatus() == AuctionRoomStatus.SOLD
                || room.getStatus() == AuctionRoomStatus.FAILED;
    }

    private String resolveWinnerListStatus(AuctionRoom room) {
        if (room.getStatus() == AuctionRoomStatus.SOLD) return "paid";
        if (room.getStatus() == AuctionRoomStatus.FAILED) return "failed";
        return "won";
    }

    private boolean matchesSearch(AdminWinnerResponse winner, String search) {
        if (search == null) return true;
        String loweredSearch = search.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(winner.getProductName(), loweredSearch)
                || containsIgnoreCase(winner.getWinnerName(), loweredSearch);
    }

    private boolean matchesStatus(AdminWinnerResponse winner, String status) {
        return status == null || winner.getStatus().equalsIgnoreCase(status);
    }

    private boolean containsIgnoreCase(String value, String loweredSearch) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(loweredSearch);
    }

    private String normalize(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
