package com.application.auction.service;

import com.application.auction.dto.request.WithdrawalCreateRequest;
import com.application.auction.dto.request.WithdrawalReviewRequest;
import com.application.auction.dto.response.WithdrawalResponse;
import com.application.auction.entity.User;
import com.application.auction.entity.WithdrawalRequest;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.WithdrawalStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.WithdrawalMapper;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.repository.WithdrawalRequestRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class WithdrawalService {
    @Autowired
    WithdrawalRequestRepository withdrawalRequestRepository;
    AuctionDepositRepository auctionDepositRepository;
    UserRepository userRepository;
    ProfileRepository profileRepository;
    WithdrawalMapper withdrawalMapper;

    @Transactional(readOnly = true)
    public List<WithdrawalResponse> getMyWithdrawals() {
        User currentUser = getCurrentUser();
        return withdrawalRequestRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public WithdrawalResponse createWithdrawal(WithdrawalCreateRequest request) {
        User currentUser = getCurrentUser();
        BigDecimal amount = requirePositiveAmount(request.getAmount());
        BigDecimal available = getWithdrawableBalance(currentUser.getId());
        if (amount.compareTo(available) > 0) {
            throw new AppException(ErrorCode.WITHDRAWAL_BALANCE_NOT_ENOUGH);
        }

        WithdrawalCreateRequest sanitizedRequest = WithdrawalCreateRequest.builder()
                .amount(amount)
                .bankName(requireText(request.getBankName(), ErrorCode.WITHDRAWAL_BANK_REQUIRED))
                .accountNumber(requireText(request.getAccountNumber(), ErrorCode.WITHDRAWAL_BANK_REQUIRED))
                .accountHolderName(requireText(request.getAccountHolderName(), ErrorCode.WITHDRAWAL_BANK_REQUIRED))
                .branchName(normalize(request.getBranchName()))
                .userNote(normalize(request.getUserNote()))
                .build();

        WithdrawalRequest withdrawal = withdrawalMapper.toWithdrawalRequest(sanitizedRequest);
        withdrawal.setUserId(currentUser.getId());
        withdrawal.setStatus(WithdrawalStatus.PENDING);
        withdrawal.setRequestedAt(Instant.now());

        return toResponse(withdrawalRequestRepository.save(withdrawal));
    }

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public List<WithdrawalResponse> getWithdrawals(String status) {
        if (status == null || status.isBlank() || status.equalsIgnoreCase("ALL")) {
            return withdrawalRequestRepository.findAll().stream()
                    .map(this::toResponse)
                    .toList();
        }
        WithdrawalStatus withdrawalStatus;
        try {
            withdrawalStatus = WithdrawalStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException exception) {
            throw new AppException(ErrorCode.WITHDRAWAL_STATUS_INVALID);
        }
        return withdrawalRequestRepository.findByStatusOrderByCreatedAtDesc(withdrawalStatus)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public WithdrawalResponse reviewWithdrawal(UUID withdrawalId, WithdrawalReviewRequest request) {
        WithdrawalRequest withdrawal = withdrawalRequestRepository.findById(withdrawalId)
                .orElseThrow(() -> new AppException(ErrorCode.WITHDRAWAL_NOT_FOUND));

        if (withdrawal.getStatus() != WithdrawalStatus.PENDING) {
            throw new AppException(ErrorCode.WITHDRAWAL_REVIEW_INVALID);
        }

        if (request.getStatus() != WithdrawalStatus.COMPLETED
                && request.getStatus() != WithdrawalStatus.REJECTED) {
            throw new AppException(ErrorCode.WITHDRAWAL_REVIEW_INVALID);
        }

        withdrawal.setStatus(request.getStatus());
        withdrawal.setAdminNote(normalize(request.getAdminNote()));
        withdrawal.setReviewedAt(Instant.now());
        if (request.getStatus() == WithdrawalStatus.COMPLETED) {
            withdrawal.setCompletedAt(Instant.now());
        }

        return toResponse(withdrawalRequestRepository.save(withdrawal));
    }

    private BigDecimal getWithdrawableBalance(UUID userId) {
        BigDecimal refunded = auctionDepositRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .filter(deposit -> deposit.getStatus() == AuctionDepositStatus.REFUNDED)
                .map(deposit -> deposit.getRequiredAmount() == null ? BigDecimal.ZERO : deposit.getRequiredAmount())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal requested = withdrawalRequestRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .filter(withdrawal -> withdrawal.getStatus() == WithdrawalStatus.PENDING
                        || withdrawal.getStatus() == WithdrawalStatus.COMPLETED)
                .map(withdrawal -> withdrawal.getAmount() == null ? BigDecimal.ZERO : withdrawal.getAmount())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal available = refunded.subtract(requested);
        return available.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : available;
    }

    private WithdrawalResponse toResponse(WithdrawalRequest withdrawal) {
        WithdrawalResponse response = withdrawalMapper.toWithdrawalResponse(withdrawal);

        userRepository.findById(withdrawal.getUserId()).ifPresent(user -> {
            response.setUsername(user.getUsername());
            response.setUserEmail(user.getEmail());
        });
        profileRepository.findById(withdrawal.getUserId()).ifPresent(profile -> {
            response.setUserFullName(profile.getFullName());
            if (response.getUserEmail() == null || response.getUserEmail().isBlank()) {
                response.setUserEmail(profile.getEmail());
            }
        });
        return response;
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private BigDecimal requirePositiveAmount(BigDecimal value) {
        if (value == null || value.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.WITHDRAWAL_AMOUNT_INVALID);
        }
        return value;
    }

    private String requireText(String value, ErrorCode errorCode) {
        String normalized = normalize(value);
        if (normalized == null) {
            throw new AppException(errorCode);
        }
        return normalized;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
