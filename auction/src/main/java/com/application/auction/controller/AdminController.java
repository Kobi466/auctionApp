package com.application.auction.controller;

import com.application.auction.dto.request.AdminNotificationRequest;
import com.application.auction.dto.request.AdminUserStatusRequest;
import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.dto.response.AdminUserResponse;
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
