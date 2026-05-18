package com.application.auction.service;

import com.application.auction.dto.request.AdminNotificationRequest;
import com.application.auction.dto.request.AdminUserStatusRequest;
import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.dto.response.AdminUserResponse;
import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.entity.KycDetail;
import com.application.auction.entity.Notification;
import com.application.auction.entity.Profile;
import com.application.auction.entity.RefreshToken;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.KycStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AdminUserMapper;
import com.application.auction.mapper.NotificationMapper;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.KycDetailRepository;
import com.application.auction.repository.NotificationRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.RefreshTokenRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminUserService {

    UserRepository userRepository;
    ProductRepository productRepository;
    AuctionRoomRepository auctionRoomRepository;
    KycDetailRepository kycDetailRepository;
    ProfileRepository profileRepository;
    NotificationRepository notificationRepository;
    RefreshTokenRepository refreshTokenRepository;
    AdminUserMapper adminUserMapper;
    NotificationMapper notificationMapper;

    public AdminDashboardSummaryResponse getDashboardSummary() {
        return AdminDashboardSummaryResponse.builder()
                .totalUsers(userRepository.count())
                .totalProducts(productRepository.count())
                .totalAuctionRooms(auctionRoomRepository.count())
                .totalPendingKyc(kycDetailRepository.countByStatus(KycStatus.PENDING))
                .totalVerifiedKyc(kycDetailRepository.countByStatus(KycStatus.VERIFIED))
                .totalRejectedKyc(kycDetailRepository.countByStatus(KycStatus.REJECTED))
                .build();
    }

    public List<AdminUserResponse> getUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToAdminUserResponse)
                .toList();
    }

    public AdminUserResponse updateUserStatus(UUID userId, AdminUserStatusRequest request) {
        if (request.getActive() == null) {
            throw new AppException(ErrorCode.USER_STATUS_REQUIRED);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        User currentAdmin = getCurrentAdmin();
        if (currentAdmin.getId().equals(user.getId()) && !request.getActive()) {
            throw new AppException(ErrorCode.CANNOT_LOCK_SELF);
        }

        user.setActive(request.getActive());
        User savedUser = userRepository.save(user);
        notifyAccountStatus(savedUser, normalize(request.getReason()));
        return mapToAdminUserResponse(savedUser);
    }

    public NotificationResponse sendNotification(UUID userId, AdminNotificationRequest request) {
        userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        Notification notification = createNotification(
                userId,
                normalize(request.getTitle()),
                normalize(request.getMessage()),
                normalize(request.getType()) == null ? "ADMIN_MESSAGE" : normalize(request.getType())
        );
        return notificationMapper.toNotificationResponse(notification);
    }

    private void notifyAccountStatus(User user, String reason) {
        if (!user.isActive()) {
            revokeRefreshTokens(user.getId());
            createNotification(
                    user.getId(),
                    "Tai khoan da bi khoa",
                    reason == null
                            ? "Tai khoan cua ban da bi khoa boi quan tri vien."
                            : "Tai khoan cua ban da bi khoa. Ly do: " + reason,
                    "ACCOUNT_LOCKED"
            );
            return;
        }

        createNotification(
                user.getId(),
                "Tai khoan da duoc mo khoa",
                reason == null
                        ? "Tai khoan cua ban da duoc mo khoa."
                        : "Tai khoan cua ban da duoc mo khoa. Ghi chu: " + reason,
                "ACCOUNT_UNLOCKED"
        );
    }

    private AdminUserResponse mapToAdminUserResponse(User user) {
        Profile profile = profileRepository.findById(user.getId()).orElse(null);
        KycDetail kycDetail = kycDetailRepository.findTopByUserIdOrderByCreatedAtDesc(user.getId()).orElse(null);
        return adminUserMapper.toAdminUserResponse(user, profile, kycDetail);
    }

    private User getCurrentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private void revokeRefreshTokens(UUID userId) {
        List<RefreshToken> refreshTokens = refreshTokenRepository.findByUserIdAndRevokedFalse(userId);
        refreshTokens.forEach(refreshToken -> refreshToken.setRevoked(true));
        refreshTokenRepository.saveAll(refreshTokens);
    }

    private Notification createNotification(UUID userId, String title, String message, String type) {
        if (title == null || message == null) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }

        return notificationRepository.save(Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type(type == null ? "ADMIN_MESSAGE" : type)
                .build());
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
