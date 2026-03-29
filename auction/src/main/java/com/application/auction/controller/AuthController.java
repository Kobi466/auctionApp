package com.application.auction.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Set;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.application.auction.dto.ApiResponse;
import com.application.auction.dto.request.AuthenticatedRequest;
import com.application.auction.dto.response.AuthenticatedResponse;
import com.application.auction.dto.response.PermissionResponse;
import com.application.auction.dto.response.RoleResponse;
import com.application.auction.dto.response.TokenResponse;
import com.application.auction.dto.response.UserResponse;
import com.application.auction.enums.SuccessCode;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
public class AuthController {
    @PostMapping("/login")
    ApiResponse<AuthenticatedResponse> login(@RequestBody @Valid AuthenticatedRequest authenticatedRequest)
            throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        return ApiResponse.ok(
                AuthenticatedResponse.builder()
                        .user(UserResponse.builder()
                                .id("e247c5b9-c96a-4552-8dc6-c5cca84dc78e")
                                .email("loi@gmail.com")
                                .isActive(true)
                                .roles(Set.of(RoleResponse.builder()
                                        .roleName("USER")
                                        .description("User role")
                                        .permissions(Set.of(
                                                PermissionResponse.builder()
                                                        .name("BAN_USER")
                                                        .description("Permission to BAN_USER")
                                                        .build()))
                                        .build()))
                                .build())
                        .token(TokenResponse.builder()
                                .accessToken("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJlMjQ3YzViOS1jOTZhLTQ1NTItOGRjNi1jNWNjYTg0ZGM3OGUiLCJzY29wZSI6IlJPTEVfVVNFUiBSRUFEX1BST0RVQ1QgV0FUQ0hfQVVDVElPTiBVUExPQURfS1lDIFZFUklGWV9LWUMgQ1JFQVRFX1BST0RVQ1QgRVhFQ1VURV9QQVlNRU5UIFJFQURfV0FMTEVUIFVQREFURV9QUk9GSUxFIFVQREFURV9QUk9EVUNUX0FVRElUIEFQUFJPVkVfUFJPRFVDVCBCTE9DS19CQUxBTkNFIERFTEVURV9QUk9EVUNUIERFUE9TSVRfTU9ORVkgQ0FOQ0VMX0FVQ1RJT04gUExBQ0VfQklEIFNUQVJUX0FVQ1RJT04gUkVBRF9BTExfUFJPRklMRVMgUkVBRF9QUk9GSUxFIEJBTl9VU0VSIiwiaXNzIjoiY29tLnRhbmxvaS5hdWN0aW9uIiwiZXhwIjoxNzc1MDE2ODE1LCJpYXQiOjE3NzQ3NTc2MTUsImVtYWlsIjoibG9pQGdtYWlsLmNvbSIsImp0aSI6ImEwYTFkZGMyLWM4NDktNGQ5NC1hMDEwLWI2YWExMmU4OGMwMiJ9.UxsFUTZB5-MqSjgagi9YIETQ9M-INPORf4uPWcQ4c2A_eWbgkhTiCx9BZ_O40cMwEc4YcZEYOjQct5FaQadeNg")
                                .refreshToken("eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJjb20udGFubG9pLmF1Y3Rpb24iLCJzdWIiOiJlMjQ3YzViOS1jOTZhLTQ1NTItOGRjNi1jNWNjYTg0ZGM3OGUiLCJ0eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3NTM2MjQxNSwiaWF0IjoxNzc0NzU3NjE1LCJqdGkiOiJmZTBkNDdjMy05ZjVmLTRiZWYtYWFiNC03ZTMyMWZiMDAyNGQifQ.VAiCF9f1yHw9C2p0RxNqUC1_9Jfu3ApyGZ1FbKMS_GPA_u1JtUZnxsskFcv6pWBRWkZTZlLohv5mLPaL5Isd4Q")
                                .accessExpiresAt(sdf.parse("2026-04-01 11:13:35"))
                                .refreshExpiresAt(sdf.parse("2026-04-05 11:13:35"))
                                .accessIssuedAt(sdf.parse("2026-03-29 11:13:35"))
                                .refreshIssuedAt(sdf.parse("2026-03-29 11:13:35"))
                                .accessExpirationTime(259199)
                                .refreshExpirationTime(604799)
                                .build())
                        .build(),
                SuccessCode.AUTHENTICATED_SUCCESS);
    }
}

