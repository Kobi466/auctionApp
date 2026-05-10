package com.application.auction.service;

import com.application.auction.dto.request.AuctionDepositReviewRequest;
import com.application.auction.dto.request.AuctionDepositSubmitRequest;
import com.application.auction.dto.response.AuctionDepositResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionPaymentConfig;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.AuctionRoomStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionDepositMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
//xử lý đặt cọc: submit payment, list deposit, admin duyệt/từ chối/hoàn cọc.
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class AuctionDepositService {
    @Autowired
    AuctionDepositRepository auctionDepositRepository;
    AuctionRoomRepository auctionRoomRepository;
    ProductRepository productRepository;
    ProfileRepository profileRepository;
    UserRepository userRepository;
    AuctionDepositMapper auctionDepositMapper;

    @Transactional
    public AuctionDeposit createOrUpdatePendingDeposit(
            UUID productId,
            AuctionRoom room,
            User currentUser,
            AuctionPaymentConfig config
    ) {
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), currentUser.getId())
                .orElse(null);

        if (deposit == null || deposit.getStatus() == AuctionDepositStatus.REJECTED) {
            deposit = AuctionDeposit.builder()
                    .auctionRoomId(room.getId())
                    .productId(productId)
                    .userId(currentUser.getId())
                    .requiredAmount(room.getMinimumBid())
                    .transferContent(buildTransferContent(config, room, currentUser))
                    .status(AuctionDepositStatus.PENDING_PAYMENT)
                    .build();
        } else if (deposit.getStatus() == AuctionDepositStatus.PENDING_PAYMENT) {
            deposit.setRequiredAmount(room.getMinimumBid());
            deposit.setTransferContent(buildTransferContent(config, room, currentUser));
        }
        return auctionDepositRepository.save(deposit);
    }

    @Transactional
    public AuctionDepositResponse submitPayment(UUID depositId, AuctionDepositSubmitRequest request) {
        User currentUser = getCurrentUser();
        AuctionDeposit deposit = auctionDepositRepository.findById(depositId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_NOT_FOUND));
        AuctionRoom room = auctionRoomRepository.findById(deposit.getAuctionRoomId())
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        ensureRegistrationWindowOpen(room);

        if (!deposit.getUserId().equals(currentUser.getId())) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        if (deposit.getStatus() == AuctionDepositStatus.APPROVED) {
            return toDepositResponse(deposit);
        }

        deposit.setStatus(AuctionDepositStatus.PENDING_APPROVAL);
        deposit.setUserNote(request == null ? null : normalize(request.getUserNote()));
        deposit.setPaymentSubmittedAt(Instant.now());
        return toDepositResponse(auctionDepositRepository.save(deposit));
    }

    @Transactional(readOnly = true)
    public List<AuctionDepositResponse> getMyDeposits() {
        User currentUser = getCurrentUser();
        return auctionDepositRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId()).stream()
                .map(this::toDepositResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public List<AuctionDepositResponse> getDeposits(String status) {
        if (status == null || status.isBlank()) {
            return auctionDepositRepository.findAll().stream().map(this::toDepositResponse).toList();
        }
        AuctionDepositStatus depositStatus;
        try {
            depositStatus = AuctionDepositStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException exception) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_STATUS_INVALID);
        }
        return auctionDepositRepository.findByStatus(depositStatus).stream()
                .map(this::toDepositResponse)
                .toList();
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AuctionDepositResponse reviewDeposit(UUID depositId, AuctionDepositReviewRequest request) {
        AuctionDeposit deposit = auctionDepositRepository.findById(depositId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_NOT_FOUND));

        if (request.getStatus() != AuctionDepositStatus.APPROVED
                && request.getStatus() != AuctionDepositStatus.REJECTED
                && request.getStatus() != AuctionDepositStatus.REFUNDED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_REVIEW_INVALID);
        }

        if (request.getStatus() == AuctionDepositStatus.REFUNDED) {
            if (deposit.getStatus() != AuctionDepositStatus.APPROVED) {
                throw new AppException(ErrorCode.AUCTION_DEPOSIT_REVIEW_INVALID);
            }
            AuctionRoom room = auctionRoomRepository.findById(deposit.getAuctionRoomId())
                    .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
            if (room.getEndTime().isAfter(Instant.now())) {
                throw new AppException(ErrorCode.AUCTION_DEPOSIT_REVIEW_INVALID);
            }
        }

        deposit.setStatus(request.getStatus());
        deposit.setAdminNote(normalize(request.getAdminNote()));
        if (request.getStatus() == AuctionDepositStatus.APPROVED) {
            deposit.setApprovedAt(Instant.now());
        } else if (request.getStatus() == AuctionDepositStatus.REJECTED) {
            deposit.setApprovedAt(null);
        }
        return toDepositResponse(auctionDepositRepository.save(deposit));
    }

    public AuctionDepositResponse toDepositResponse(AuctionDeposit deposit) {
        if (deposit == null) {
            return null;
        }
        AuctionDepositResponse response = auctionDepositMapper.toAuctionDepositResponse(deposit);
        productRepository.findById(deposit.getProductId())
                .ifPresent(product -> response.setProductName(product.getName()));
        userRepository.findById(deposit.getUserId()).ifPresent(user -> {
            response.setUsername(user.getUsername());
            response.setUserEmail(user.getEmail());
        });
        profileRepository.findById(deposit.getUserId()).ifPresent(profile -> {
            response.setUserFullName(profile.getFullName());
            if (response.getUserEmail() == null || response.getUserEmail().isBlank()) {
                response.setUserEmail(profile.getEmail());
            }
        });
        return response;
    }

    private void ensureRegistrationWindowOpen(AuctionRoom room) {
        if (room.getStatus() == AuctionRoomStatus.CANCELLED) {
            throw new AppException(ErrorCode.AUCTION_ROOM_CLOSED);
        }
        Instant now = Instant.now();
        if (now.isBefore(room.getStartTime())) {
            return;
        }
        if (now.isBefore(room.getEndTime())) {
            throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_STARTED);
        }
        throw new AppException(ErrorCode.AUCTION_ROOM_CLOSED);
    }

    private String buildTransferContent(AuctionPaymentConfig config, AuctionRoom room, User currentUser) {
        String prefix = normalize(config.getTransferNotePrefix());
        String code = (prefix == null ? "AUC" : prefix).toUpperCase();
        return code + "-" + room.getId().toString().substring(0, 8) + "-" + currentUser.getId().toString().substring(0, 8);
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
