package com.application.auction.service;

import com.application.auction.dto.response.AuctionParticipationStatusResponse;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.entity.AuctionPaymentConfig;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.AuctionRoomStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.KycStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionPaymentConfigMapper;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.KycDetailRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;
//duyetien
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
    AuctionDepositService auctionDepositService;
    KycDetailService kycDetailService;
    KycDetailRepository kycDetailRepository;
    UserRepository userRepository;
    AuctionPaymentConfigMapper auctionPaymentConfigMapper;
    AuctionRoomMapper auctionRoomMapper;

    @Transactional(readOnly = true)
    public AuctionParticipationStatusResponse getParticipationStatus(UUID productId) {
        ProductResponse product = productService.getProduct(productId);
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);
        AuctionDeposit deposit = getCurrentDeposit(room, currentUser);
        AuctionPaymentConfig config = getActivePaymentConfigOrNull();

        return buildStatusResponse(
                product,
                isKycVerified(currentUser),
                deposit,
                config,
                canAccessRoom(deposit, room)
        );
    }

    @Transactional
    public AuctionParticipationStatusResponse confirmRules(UUID productId) {
        kycDetailService.ensureCurrentUserVerifiedForAuction();

        ProductResponse product = productService.getProduct(productId);
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);
        ensureRegistrationWindowOpen(room);
        AuctionPaymentConfig config = auctionPaymentConfigService.getActiveEntity();
        AuctionDeposit deposit = auctionDepositService.createOrUpdatePendingDeposit(productId, room, currentUser, config);

        return buildStatusResponse(product, true, deposit, config, canAccessRoom(deposit, room));
    }

    @Transactional(readOnly = true)
    public AuctionRoomAccessResponse getRoomAccess(UUID productId) {
        kycDetailService.ensureCurrentUserVerifiedForAuction();
        User currentUser = getCurrentUser();
        AuctionRoom room = getRoom(productId);
        AuctionRoomStatus roomStatus = resolveAuctionRoomStatus(room);
        if (roomStatus == AuctionRoomStatus.CLOSED || roomStatus == AuctionRoomStatus.CANCELLED) {
            throw new AppException(ErrorCode.AUCTION_ROOM_CLOSED);
        }
        AuctionDeposit deposit = getCurrentDeposit(room, currentUser);
        if (deposit == null) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_REQUIRED);
        }
        if (deposit.getStatus() != AuctionDepositStatus.APPROVED) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_APPROVAL_REQUIRED);
        }

        return auctionRoomMapper.toAuctionRoomAccessResponse(room);
    }

    private AuctionParticipationStatusResponse buildStatusResponse(
            ProductResponse product,
            boolean kycVerified,
            AuctionDeposit deposit,
            AuctionPaymentConfig config,
            boolean roomAccessGranted
    ) {
        return AuctionParticipationStatusResponse.builder()
                .kycVerified(kycVerified)
                .product(product)
                .auctionRules(AUCTION_RULES)
                .agreedToRules(deposit != null)
                .deposit(auctionDepositService.toDepositResponse(deposit))
                .paymentConfig(toPaymentConfigResponse(config))
                .roomAccessGranted(roomAccessGranted)
                .build();
    }

    private boolean canAccessRoom(AuctionDeposit deposit, AuctionRoom room) {
        AuctionRoomStatus roomStatus = resolveAuctionRoomStatus(room);
        return deposit != null
                && deposit.getStatus() == AuctionDepositStatus.APPROVED
                && roomStatus != AuctionRoomStatus.CLOSED
                && roomStatus != AuctionRoomStatus.CANCELLED;
    }

    private AuctionDeposit getCurrentDeposit(AuctionRoom room, User currentUser) {
        return auctionDepositRepository
                .findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(room.getId(), currentUser.getId())
                .orElse(null);
    }

    private AuctionRoom getRoom(UUID productId) {
        return auctionRoomRepository.findByProductId(productId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
    }

    private AuctionRoomStatus resolveAuctionRoomStatus(AuctionRoom room) {
        Instant now = Instant.now();
        if (room.getStatus() == AuctionRoomStatus.CANCELLED) {
            return AuctionRoomStatus.CANCELLED;
        }
        if (now.isAfter(room.getEndTime())) {
            return AuctionRoomStatus.CLOSED;
        }
        if (now.isBefore(room.getStartTime())) {
            return AuctionRoomStatus.SCHEDULED;
        }
        return AuctionRoomStatus.LIVE;
    }

    private void ensureRegistrationWindowOpen(AuctionRoom room) {
        AuctionRoomStatus status = resolveAuctionRoomStatus(room);
        if (status == AuctionRoomStatus.SCHEDULED) {
            return;
        }
        if (status == AuctionRoomStatus.LIVE) {
            throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_STARTED);
        }
        throw new AppException(ErrorCode.AUCTION_ROOM_CLOSED);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private boolean isKycVerified(User currentUser) {
        return kycDetailRepository
                .findTopByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .map(kycDetail -> kycDetail.getStatus() == KycStatus.VERIFIED)
                .orElse(false);
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

    private AuctionPaymentConfigResponse toPaymentConfigResponse(AuctionPaymentConfig config) {
        if (config == null) {
            return null;
        }
        return auctionPaymentConfigMapper.toAuctionPaymentConfigResponse(config);
    }
}
