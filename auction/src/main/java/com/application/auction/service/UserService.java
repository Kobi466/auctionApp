package com.application.auction.service;

import com.application.auction.dto.request.UserCreationRequest;
import com.application.auction.dto.request.UserUpdateRequest;
import com.application.auction.dto.response.UserResponse;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.Role;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.UserMapper;
import com.application.auction.repository.RoleRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.UUID;


@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class UserService {
    @Autowired
    UserRepository userRepository;
    UserMapper userMapper;
    PasswordEncoder passwordEncoder;
    RoleRepository roleRepository;
    ProfileService profileService;


    @Transactional
    public UserResponse createUser(UserCreationRequest userCreationRequest) {
        if(userRepository.existsByEmail(userCreationRequest.getEmail()))
            throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);

        String normalizedPhone = normalize(userCreationRequest.getPhone());
        if (normalizedPhone != null && userRepository.existsByPhone(normalizedPhone)) {
            throw new AppException(ErrorCode.PHONE_NUMBER_ALREADY_EXISTS);
        }

        var defaultRole = roleRepository.findByName(Role.USER.name())
                .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));

        User user = userMapper.toUser(userCreationRequest);
        user.setUsername(userCreationRequest.getEmail());
        user.setPhone(normalizedPhone);
        user.setPassword(passwordEncoder.encode(userCreationRequest.getPassword()));
        user.setRoles(new HashSet<>(List.of(defaultRole)));
        user = userRepository.save(user);
        profileService.createRegistrationProfile(
                user,
                userCreationRequest.getFullName(),
                userCreationRequest.getPhone()
        );
        return userMapper.toUserResponse(user);
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getAllUser() {
        return userRepository
                .findAll().stream()
                .map(userMapper::toUserResponse)
                .toList();
    }
    @PostAuthorize("hasRole('ADMIN') or returnObject.email == authentication.name")
    public UserResponse getUserById(UUID id) {
        return userRepository.findById(id)
                .map(userMapper::toUserResponse)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    @Transactional
    public UserResponse update(UUID id, UserUpdateRequest request) {
        User user = userRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        userMapper.updateUser(user,request); // map du lieu
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        var roles = roleRepository.findAllById(request.getRoles());
        user.setRoles(new HashSet<>(roles));
        user.setUsername(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user = userRepository.save(user);
        profileService.ensureProfileExists(user);
        return userMapper.toUserResponse(user);
    }

    public UserResponse getMyInfo() {
        var email = SecurityContextHolder.getContext().getAuthentication().getName();
        log.info("Current email: {}", email);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        return userMapper.toUserResponse(user);
    }


}
