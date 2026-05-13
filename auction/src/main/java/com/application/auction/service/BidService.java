package com.application.auction.service;

import com.application.auction.dto.request.BidRequest;
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
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

// xử lý lượt đấu
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class BidService {
    @Autowired
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

    @Transactional
    public BidResponse placeBid(UUID roomId, BidRequest request) {
        User currentUser = getCurrentUser();
        AuctionRoom auctionRoom = auctionRoomRepository.findById(roomId)
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

        BigDecimal amount = request == null ? null : request.getAmount();
        BigDecimal currentPrice = getCurrentPrice(auctionRoom);
        if (amount == null || amount.compareTo(currentPrice) <= 0) {
            throw new AppException(ErrorCode.BID_AMOUNT_INVALID);
        }

        Bid bid = Bid.builder()
                .auctionRoom(auctionRoom)
                .bidder(currentUser)
                .amount(amount)
                .timestamp(Instant.now())
                .build();
        Bid savedBid = bidRepository.save(bid);
        return toBidResponse(savedBid, true);
    }

    private BidResponse toBidResponse(Bid bid, boolean leading) {
        BidResponse response = bidMapper.toBidResponse(bid);
        response.setLeading(leading);
        userRepository.findById(bid.getBidder().getId()).ifPresent(user -> {
            response.setUserName(maskName(user.getUsername()));
        });
        profileRepository.findById(bid.getBidder().getId()).ifPresent(profile -> {
            response.setUserAvatar(profile.getAvatar());
            if (profile.getFullName() != null && !profile.getFullName().isBlank()) {
                response.setUserName(maskName(profile.getFullName()));
            }
        });
        return response;
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

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private String maskName(String value) {
        if (value == null || value.isBlank()) {
            return "Nguoi dung";
        }
        String trimmed = value.trim();
        if (trimmed.length() <= 2) {
            return trimmed.charAt(0) + "***";
        }
        return trimmed.substring(0, Math.min(4, trimmed.length())) + "***";
    }
}
