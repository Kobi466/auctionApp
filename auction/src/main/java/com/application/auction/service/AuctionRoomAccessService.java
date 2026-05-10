package com.application.auction.service;

import com.application.auction.dto.request.AuctionRoomJoinRequest;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
//xu ly cho vao phong
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class AuctionRoomAccessService {
    @Autowired
    AuctionRoomRepository auctionRoomRepository;
    AuctionDepositRepository auctionDepositRepository;
    UserRepository userRepository;
    AuctionRoomMapper auctionRoomMapper;

    @Transactional(readOnly = true)
    public AuctionRoomAccessResponse joinAuctionRoom(AuctionRoomJoinRequest request) {
        User currentUser = getCurrentUser();
        String roomCode = request == null ? null : normalize(request.getRoomCode());
        String roomPassword = request == null ? null : normalize(request.getRoomPassword());
        if (roomCode == null || roomPassword == null) {
            throw new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND);
        }
        AuctionRoom auctionRoom = auctionRoomRepository.findByRoomCode(roomCode)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        if (!roomPassword.equals(auctionRoom.getRoomPassword())) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(auctionRoom.getId(), currentUser.getId())
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_REQUIRED));
        if (deposit.getStatus() != AuctionDepositStatus.APPROVED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_APPROVAL_REQUIRED);
        }
        return auctionRoomMapper.toAuctionRoomAccessResponse(auctionRoom);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
