package com.application.auction.controller;

import com.application.auction.dto.request.AdminNotificationRequest;
import com.application.auction.dto.request.AdminUserStatusRequest;
import com.application.auction.dto.request.AdminWinnerPaymentReviewRequest;
import com.application.auction.dto.request.AdminWinnerRankActionRequest;
import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.dto.response.AdminUserResponse;
import com.application.auction.dto.response.AdminWinnerCandidateResponse;
import com.application.auction.dto.response.AdminWinnerResponse;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.service.AdminService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminController {

    AdminService adminService;

    @GetMapping("/dashboard-summary")
    public ApiResponse<AdminDashboardSummaryResponse> getDashboardSummary() {
        return ApiResponse.<AdminDashboardSummaryResponse>builder()
                .result(adminService.getDashboardSummary())
                .build();
    }

    @GetMapping("/users")
    public ApiResponse<List<AdminUserResponse>> getUsers() {
        return ApiResponse.<List<AdminUserResponse>>builder()
                .result(adminService.getUsers())
                .build();
    }

    @GetMapping("/winners")
    public ApiResponse<List<AdminWinnerResponse>> getWinners(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.<List<AdminWinnerResponse>>builder()
                .result(adminService.getWinners(search, status))
                .build();
    }

    @GetMapping("/winners/{roomId}/ranking")
    public ApiResponse<List<AdminWinnerCandidateResponse>> getWinnerRanking(@PathVariable UUID roomId) {
        return ApiResponse.<List<AdminWinnerCandidateResponse>>builder()
                .result(adminService.getWinnerRanking(roomId))
                .build();
    }

    @PostMapping("/winners/{roomId}/offer")
    public ApiResponse<NotificationResponse> sendWinnerOffer(
            @PathVariable UUID roomId,
            @RequestBody AdminWinnerRankActionRequest request
    ) {
        return ApiResponse.<NotificationResponse>builder()
                .result(adminService.sendWinnerOffer(roomId, request))
                .build();
    }

    @PostMapping("/winners/{roomId}/forfeit")
    public ApiResponse<NotificationResponse> forfeitWinnerRank(
            @PathVariable UUID roomId,
            @RequestBody AdminWinnerRankActionRequest request
    ) {
        return ApiResponse.<NotificationResponse>builder()
                .result(adminService.forfeitWinnerRank(roomId, request))
                .build();
    }

    @PostMapping("/winners/{roomId}/refund")
    public ApiResponse<List<AdminWinnerCandidateResponse>> refundWinnerRank(
            @PathVariable UUID roomId,
            @RequestBody AdminWinnerRankActionRequest request
    ) {
        return ApiResponse.<List<AdminWinnerCandidateResponse>>builder()
                .result(adminService.refundWinnerRank(roomId, request))
                .build();
    }

    @PostMapping("/winners/{roomId}/refund-losing-deposits")
    public ApiResponse<List<AdminWinnerCandidateResponse>> refundLosingDeposits(@PathVariable UUID roomId) {
        return ApiResponse.<List<AdminWinnerCandidateResponse>>builder()
                .result(adminService.refundLosingDeposits(roomId))
                .build();
    }

    @PostMapping("/winners/{roomId}/payment/confirm")
    public ApiResponse<List<AdminWinnerCandidateResponse>> confirmWinnerPayment(
            @PathVariable UUID roomId,
            @RequestBody(required = false) AdminWinnerPaymentReviewRequest request
    ) {
        return ApiResponse.<List<AdminWinnerCandidateResponse>>builder()
                .result(adminService.confirmWinnerPayment(roomId, request))
                .build();
    }

    @PostMapping("/winners/{roomId}/payment/reject")
    public ApiResponse<List<AdminWinnerCandidateResponse>> rejectWinnerPayment(
            @PathVariable UUID roomId,
            @RequestBody(required = false) AdminWinnerPaymentReviewRequest request
    ) {
        return ApiResponse.<List<AdminWinnerCandidateResponse>>builder()
                .result(adminService.rejectWinnerPayment(roomId, request))
                .build();
    }

    @PatchMapping("/users/{userId}/status")
    public ApiResponse<AdminUserResponse> updateUserStatus(
            @PathVariable UUID userId,
            @RequestBody AdminUserStatusRequest request
    ) {
        return ApiResponse.<AdminUserResponse>builder()
                .result(adminService.updateUserStatus(userId, request))
                .build();
    }

    @PostMapping("/users/{userId}/notifications")
    public ApiResponse<NotificationResponse> sendNotification(
            @PathVariable UUID userId,
            @RequestBody @Valid AdminNotificationRequest request
    ) {
        return ApiResponse.<NotificationResponse>builder()
                .result(adminService.sendNotification(userId, request))
                .build();
    }
}
