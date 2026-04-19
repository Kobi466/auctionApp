package com.application.auction.service;

import com.application.auction.dto.request.AuctionDepositReviewRequest;
import com.application.auction.dto.request.AuctionDepositSubmitRequest;
import com.application.auction.dto.response.AuctionDepositResponse;
import com.application.auction.dto.response.AuctionParticipationStatusResponse;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionPaymentConfig;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionParticipationService {

    String AUCTION_RULES = """
            1. User phai hoan tat KYC truoc khi tham gia dau gia.
            2. User phai doc ky quy che, dong y va dat coc dung so tien yeu cau.
            3. Noi dung chuyen khoan phai dung chinh xac theo huong dan he thong.
            4. Chi user duoc admin duyet coc moi nhan duoc roomId va password vao phong.
            5. Neu vi pham quy che dau gia, he thong co the tu choi quyen tham gia.
            """;

    ProductService productService;
    AuctionRoomRepository auctionRoomRepository;
    AuctionDepositRepository auctionDepositRepository;
    AuctionPaymentConfigService auctionPaymentConfigService;
    KycDetailService kycDetailService;
    UserRepository userRepository;

    @Transactional(readOnly = true)
    public AuctionParticipationStatusResponse getParticipationStatus(UUID productId) {
        ProductResponse product = productService.getProduct(productId);
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);

        boolean kycVerified = isKycVerified();
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), currentUser.getId())
                .orElse(null);
        AuctionPaymentConfig config = getActivePaymentConfigOrNull();

        return AuctionParticipationStatusResponse.builder()
                .kycVerified(kycVerified)
                .product(product)
                .auctionRules(AUCTION_RULES)
                .agreedToRules(deposit != null)
                .deposit(toDepositResponse(deposit))
                .paymentConfig(toPaymentConfigResponse(config))
                .roomAccessGranted(deposit != null && deposit.getStatus() == AuctionDepositStatus.APPROVED)
                .build();
    }

    @Transactional
    public AuctionParticipationStatusResponse confirmRules(UUID productId) {
        kycDetailService.ensureCurrentUserVerifiedForAuction();

        ProductResponse product = productService.getProduct(productId);
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);
        AuctionPaymentConfig config = auctionPaymentConfigService.getActiveEntity();

        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), currentUser.getId())
                .orElse(null);

        if (deposit == null || deposit.getStatus() == AuctionDepositStatus.REJECTED) {
            deposit = AuctionDeposit.builder()
                    .auctionRoomId(room.getId())
                    .productId(productId)
                    .userId(currentUser.getId())
                    .requiredAmount(room.getDepositAmount())
                    .transferContent(buildTransferContent(config, room, currentUser))
                    .status(AuctionDepositStatus.PENDING_PAYMENT)
                    .build();
        }

        AuctionDeposit savedDeposit = auctionDepositRepository.save(deposit);

        return AuctionParticipationStatusResponse.builder()
                .kycVerified(true)
                .product(product)
                .auctionRules(AUCTION_RULES)
                .agreedToRules(true)
                .deposit(toDepositResponse(savedDeposit))
                .paymentConfig(toPaymentConfigResponse(config))
                .roomAccessGranted(savedDeposit.getStatus() == AuctionDepositStatus.APPROVED)
                .build();
    }

    @Transactional
    public AuctionDepositResponse submitPayment(UUID depositId, AuctionDepositSubmitRequest request) {
        User currentUser = getCurrentUser();
        AuctionDeposit deposit = auctionDepositRepository.findById(depositId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_NOT_FOUND));

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
                && request.getStatus() != AuctionDepositStatus.REJECTED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_REVIEW_INVALID);
        }

        deposit.setStatus(request.getStatus());
        deposit.setAdminNote(normalize(request.getAdminNote()));
        if (request.getStatus() == AuctionDepositStatus.APPROVED) {
            deposit.setApprovedAt(Instant.now());
        } else {
            deposit.setApprovedAt(null);
        }
        return toDepositResponse(auctionDepositRepository.save(deposit));
    }

    @Transactional(readOnly = true)
    public AuctionRoomAccessResponse getRoomAccess(UUID productId) {
        kycDetailService.ensureCurrentUserVerifiedForAuction();
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);
        AuctionDeposit deposit = auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), currentUser.getId())
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_DEPOSIT_REQUIRED));

        if (deposit.getStatus() != AuctionDepositStatus.APPROVED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_APPROVAL_REQUIRED);
        }

        return AuctionRoomAccessResponse.builder()
                .roomId(room.getId().toString())
                .roomPassword(room.getRoomPassword())
                .roomCode(room.getRoomCode())
                .build();
    }

    private String buildTransferContent(AuctionPaymentConfig config, AuctionRoom room, User currentUser) {
        String prefix = normalize(config.getTransferNotePrefix());
        String code = (prefix == null ? "AUC" : prefix).toUpperCase();
        return code + "-" + room.getId().toString().substring(0, 8) + "-" + currentUser.getId().toString().substring(0, 8);
    }

    private AuctionRoom getRoom(UUID productId) {
        return auctionRoomRepository.findByProductId(productId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private boolean isKycVerified() {
        try {
            kycDetailService.ensureCurrentUserVerifiedForAuction();
            return true;
        } catch (AppException exception) {
            if (exception.getErrorCode() == ErrorCode.KYC_VERIFICATION_REQUIRED) {
                return false;
            }
            throw exception;
        }
    }

    private AuctionPaymentConfig getActivePaymentConfigOrNull() {
        try {
            return auctionPaymentConfigService.getActiveEntity();
        } catch (AppException exception) {
            if (exception.getErrorCode() == ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED) {
                return null;
            }
            throw exception;
        }
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private AuctionDepositResponse toDepositResponse(AuctionDeposit deposit) {
        if (deposit == null) {
            return null;
        }
        return AuctionDepositResponse.builder()
                .id(deposit.getId())
                .auctionRoomId(deposit.getAuctionRoomId())
                .productId(deposit.getProductId())
                .userId(deposit.getUserId())
                .requiredAmount(deposit.getRequiredAmount())
                .transferContent(deposit.getTransferContent())
                .status(deposit.getStatus())
                .adminNote(deposit.getAdminNote())
                .userNote(deposit.getUserNote())
                .paymentSubmittedAt(deposit.getPaymentSubmittedAt())
                .approvedAt(deposit.getApprovedAt())
                .createdAt(deposit.getCreatedAt())
                .updatedAt(deposit.getUpdatedAt())
                .build();
    }

    private AuctionPaymentConfigResponse toPaymentConfigResponse(AuctionPaymentConfig config) {
        if (config == null) {
            return null;
        }
        return AuctionPaymentConfigResponse.builder()
                .id(config.getId())
                .bankName(config.getBankName())
                .accountNumber(config.getAccountNumber())
                .accountHolderName(config.getAccountHolderName())
                .qrImageUrl(config.getQrImageUrl())
                .branchName(config.getBranchName())
                .transferNotePrefix(config.getTransferNotePrefix())
                .active(config.isActive())
                .createdAt(config.getCreatedAt())
                .updatedAt(config.getUpdatedAt())
                .build();
    }
}
