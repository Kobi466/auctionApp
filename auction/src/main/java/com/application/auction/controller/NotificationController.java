package com.application.auction.controller;

import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.service.NotificationService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class NotificationController {

    NotificationService notificationService;

    @GetMapping("/me")
    public ApiResponse<List<NotificationResponse>> getMyNotifications() {
        return ApiResponse.<List<NotificationResponse>>builder()
                .result(notificationService.getMyNotifications())
                .build();
    }

    @PatchMapping("/{notificationId}/read")
    public ApiResponse<NotificationResponse> markAsRead(@PathVariable UUID notificationId) {
        return ApiResponse.<NotificationResponse>builder()
                .result(notificationService.markAsRead(notificationId))
                .build();
    }
}
