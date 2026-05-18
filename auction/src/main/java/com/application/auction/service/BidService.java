package com.application.auction.service;

import com.application.auction.dto.request.BidRequest;
import com.application.auction.dto.response.AuctionRankingResponse;
import com.application.auction.dto.response.BidResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.BidMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.util.PrivacyMaskingUtil;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class BidService {
    private static final long BID_COOLDOWN_SECONDS = 5;
    private static final long LAST_MINUTE_EXTENSION_THRESHOLD_SECONDS = 60;
    private static final long LAST_MINUTE_EXTENSION_SECONDS = 120;

    BidRepository bidRepository;
    AuctionRoomRepository auctionRoomRepository;
    AuctionDepositRepository auctionDepositRepository;
    UserRepository userRepository;
    ProfileRepository profileRepository;
    BidMapper bidMapper;

    @Transactional(readOnly = true)
    public List<BidResponse> getBidHistory(UUID roomId) {
        List<Bid> bids = bidRepository.findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(roomId);
        UUID leadingBidId = bids.isEmpty() ? null : bids.get(0).getId();
        return bids.stream()
                .map(bid -> toBidResponse(bid, bid.getId().equals(leadingBidId)))
                .toList();
    }

    @Transactional(readOnly = true)
    public BigDecimal getCurrentPrice(AuctionRoom auctionRoom) {
        return bidRepository.findTopByAuctionRoomIdOrderByAmountDescCreatedAtAsc(auctionRoom.getId())
                .map(Bid::getAmount)
                .orElse(auctionRoom.getStartingPrice());
    }

    @Transactional(readOnly = true)
    public long countBid(UUID roomId) {
        return bidRepository.countByAuctionRoomId(roomId);
    }

    @Transactional(readOnly = true)
    public List<AuctionRankingResponse> getTopRankings(UUID roomId, int limit) {
        return buildTopRankings(roomId, limit);
    }

    @Transactional
    public BidResponse placeBid(UUID roomId, BidRequest request) {
        User currentUser = getCurrentUser();
        AuctionRoom auctionRoom = auctionRoomRepository.findByIdForUpdate(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        AuctionRoomStatus roomStatus = resolveAuctionRoomStatus(auctionRoom);
        if (roomStatus != AuctionRoomStatus.LIVE) {
            throw new AppException(ErrorCode.AUCTION_ROOM_NOT_STARTED);
        }

        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(roomId, currentUser.getId())
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_REQUIRED));
        if (deposit.getStatus() != AuctionDepositStatus.APPROVED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_APPROVAL_REQUIRED);
        }
        validateBidCooldown(roomId, currentUser);

        BigDecimal incrementAmount = request == null ? null : request.getAmount();
        BigDecimal currentPrice = getCurrentPrice(auctionRoom);
        if (incrementAmount == null || incrementAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.BID_AMOUNT_INVALID);
        }
        BigDecimal newPrice = currentPrice.add(incrementAmount);

        Bid bid = Bid.builder()
                .auctionRoom(auctionRoom)
                .bidder(currentUser)
                .amount(newPrice)
                .timestamp(Instant.now())
                .build();
        Bid savedBid = bidRepository.save(bid);
        auctionRoom.setCurrentPrice(newPrice);
        auctionRoom.setHighestBidder(currentUser);
        handleLastMinuteExtension(auctionRoom);
        return toBidResponse(savedBid, true);
    }

    private void validateBidCooldown(UUID roomId, User currentUser) {
        Instant cooldownStart = Instant.now().minusSeconds(BID_COOLDOWN_SECONDS);
        bidRepository.findTopByAuctionRoomIdAndBidderIdOrderByTimestampDesc(roomId, currentUser.getId())
                .filter(lastBid -> lastBid.getTimestamp() != null && lastBid.getTimestamp().isAfter(cooldownStart))
                .ifPresent(lastBid -> {
                    throw new AppException(ErrorCode.BID_COOLDOWN_ACTIVE);
                });
    }

    private BidResponse toBidResponse(Bid bid, boolean leading) {
        BidResponse response = bidMapper.toBidResponse(bid);
        response.setLeading(leading);
        userRepository.findById(bid.getBidder().getId()).ifPresent(user -> {
            response.setUserName(PrivacyMaskingUtil.maskDisplayName(user.getUsername()));
        });
        profileRepository.findById(bid.getBidder().getId()).ifPresent(profile -> {
            response.setUserAvatar(profile.getAvatar());
            if (profile.getFullName() != null && !profile.getFullName().isBlank()) {
                response.setUserName(PrivacyMaskingUtil.maskDisplayName(profile.getFullName()));
            }
        });
        return response;
    }

    private List<AuctionRankingResponse> buildTopRankings(UUID roomId, int limit) {
        Map<UUID, Bid> bestBidByUser = new LinkedHashMap<>();
        bidRepository.findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(roomId)
                .forEach(bid -> bestBidByUser.putIfAbsent(bid.getBidder().getId(), bid));

        int maxItems = Math.max(1, limit);
        final int[] rank = {0};
        return bestBidByUser.values().stream()
                .limit(maxItems)
                .map(bid -> {
                    int currentRank = ++rank[0];
                    return AuctionRankingResponse.builder()
                            .rank(currentRank)
                            .userId(bid.getBidder().getId())
                            .userName(resolveMaskedBidderName(bid))
                            .amount(bid.getAmount())
                            .bidTime(bid.getTimestamp())
                            .winner(currentRank == 1)
                            .build();
                })
                .toList();
    }

    private String resolveMaskedBidderName(Bid bid) {
        return profileRepository.findById(bid.getBidder().getId())
                .map(profile -> profile.getFullName())
                .filter(fullName -> fullName != null && !fullName.isBlank())
                .map(PrivacyMaskingUtil::maskDisplayName)
                .orElseGet(() -> PrivacyMaskingUtil.maskDisplayName(bid.getBidder().getUsername()));
    }

    private AuctionRoomStatus resolveAuctionRoomStatus(AuctionRoom auctionRoom) {
        if (auctionRoom.getStatus() == AuctionRoomStatus.CANCELLED) {
            return AuctionRoomStatus.CANCELLED;
        }
        Instant now = Instant.now();
        if (now.isBefore(auctionRoom.getStartTime())) {
            return AuctionRoomStatus.SCHEDULED;
        }
        if (now.isAfter(auctionRoom.getEndTime())) {
            return AuctionRoomStatus.CLOSED;
        }
        return AuctionRoomStatus.LIVE;
    }

    private boolean handleLastMinuteExtension(AuctionRoom auctionRoom) {
        if (auctionRoom.isTimeExtended() || auctionRoom.getEndTime() == null) return false;

        long secondsUntilEnd = java.time.Duration.between(Instant.now(), auctionRoom.getEndTime()).getSeconds();
        if (secondsUntilEnd > 0 && secondsUntilEnd <= LAST_MINUTE_EXTENSION_THRESHOLD_SECONDS) {
            auctionRoom.setEndTime(auctionRoom.getEndTime().plusSeconds(LAST_MINUTE_EXTENSION_SECONDS));
            auctionRoom.setTimeExtended(true);
            return true;
        }
        return false;
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
}
