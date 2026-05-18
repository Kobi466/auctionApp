package com.application.auction.service;

import com.application.auction.dto.request.AdminNotificationRequest;
import com.application.auction.dto.request.AdminUserStatusRequest;
import com.application.auction.dto.request.AdminWinnerPaymentReviewRequest;
import com.application.auction.dto.request.AdminWinnerRankActionRequest;
import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.dto.response.AdminUserResponse;
import com.application.auction.dto.response.AdminWinnerCandidateResponse;
import com.application.auction.dto.response.AdminWinnerResponse;
import com.application.auction.dto.response.NotificationResponse;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminService {

    AdminUserService adminUserService;
    AdminWinnerQueryService winnerQueryService;
    AdminWinnerFlowService winnerFlowService;
    AdminWinnerPaymentService winnerPaymentService;

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public AdminDashboardSummaryResponse getDashboardSummary() {
        return adminUserService.getDashboardSummary();
    }

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminUserResponse> getUsers() {
        return adminUserService.getUsers();
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerResponse> getWinners(String search, String status) {
        return winnerQueryService.getWinners(search, status);
    }

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerCandidateResponse> getWinnerRanking(UUID roomId) {
        return winnerQueryService.getWinnerRanking(roomId);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public NotificationResponse sendWinnerOffer(UUID roomId, AdminWinnerRankActionRequest request) {
        return winnerFlowService.sendOffer(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public NotificationResponse forfeitWinnerRank(UUID roomId, AdminWinnerRankActionRequest request) {
        return winnerFlowService.forfeit(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerCandidateResponse> refundWinnerRank(UUID roomId, AdminWinnerRankActionRequest request) {
        return winnerFlowService.refundRank(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerCandidateResponse> refundLosingDeposits(UUID roomId) {
        return winnerFlowService.refundLosingDeposits(roomId);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerCandidateResponse> confirmWinnerPayment(
            UUID roomId,
            AdminWinnerPaymentReviewRequest request
    ) {
        return winnerPaymentService.confirm(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public List<AdminWinnerCandidateResponse> rejectWinnerPayment(
            UUID roomId,
            AdminWinnerPaymentReviewRequest request
    ) {
        return winnerPaymentService.reject(roomId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AdminUserResponse updateUserStatus(UUID userId, AdminUserStatusRequest request) {
        return adminUserService.updateUserStatus(userId, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public NotificationResponse sendNotification(UUID userId, AdminNotificationRequest request) {
        return adminUserService.sendNotification(userId, request);
    }
}
