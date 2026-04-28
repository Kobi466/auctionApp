package com.application.auction.controller;

import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.service.AdminService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
