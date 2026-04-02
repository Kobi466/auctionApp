package com.application.auction.controller;

import com.application.auction.dto.request.UserCreationRequest;
import com.application.auction.dto.request.UserUpdateRequest;
import com.application.auction.dto.response.ApiResponse;
import com.application.auction.dto.response.UserResponse;
import com.application.auction.service.UserService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UserControler {
    @Autowired
    UserService userService;


    @PostMapping
    public UserResponse createUser(@RequestBody @Valid UserCreationRequest request) {
        ApiResponse<UserResponse> apiResponse = new ApiResponse<>();
        apiResponse.setResult(userService.createUser(request));
        return apiResponse.getResult();
    }

    @GetMapping
    ApiResponse<List<UserResponse>>getallUser() {
        ApiResponse<List<UserResponse>> apiResponse = new ApiResponse<>();
        apiResponse.setResult(userService.getAllUser());
        return apiResponse;
    }
    @GetMapping("/{id}")
    public UserResponse getUserById(@PathVariable UUID id) {
        ApiResponse<UserResponse> apiResponse = new ApiResponse<>();
        apiResponse.setResult(userService.getUserById(id));
        return apiResponse.getResult();
    }

    @PutMapping("/{id}")
    UserResponse updateUser(@PathVariable UUID id, @RequestBody @Valid UserUpdateRequest request) {
        ApiResponse<UserResponse> apiResponse = new ApiResponse<>();
        apiResponse.setResult(userService.update(id, request));
        return apiResponse.getResult();
    }
    @GetMapping("/myInfo")
    ApiResponse<UserResponse> getMyInfo() {
        return ApiResponse.<UserResponse>builder()
                .result(userService.getMyInfo())
                .build();
    }
}
