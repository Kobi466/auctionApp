package com.application.auction.service;

import com.application.auction.dto.request.AuctionPaymentConfigRequest;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.entity.AuctionPaymentConfig;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.repository.AuctionPaymentConfigRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionPaymentConfigService {

    AuctionPaymentConfigRepository auctionPaymentConfigRepository;

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AuctionPaymentConfigResponse upsert(AuctionPaymentConfigRequest request) {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findById(1L)
                .orElse(AuctionPaymentConfig.builder().id(1L).build());

        config.setBankName(requireText(request.getBankName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        config.setAccountNumber(requireText(request.getAccountNumber(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        config.setAccountHolderName(requireText(request.getAccountHolderName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        config.setQrImageUrl(requireText(request.getQrImageUrl(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        config.setBranchName(normalize(request.getBranchName()));
        config.setTransferNotePrefix(normalize(request.getTransferNotePrefix()));
        config.setActive(request.getActive() == null || request.getActive());

        return toResponse(auctionPaymentConfigRepository.save(config));
    }

    @Transactional(readOnly = true)
    public AuctionPaymentConfigResponse getActive() {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findFirstByActiveTrue()
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        return toResponse(config);
    }

    AuctionPaymentConfig getActiveEntity() {
        return auctionPaymentConfigRepository.findFirstByActiveTrue()
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
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

    private AuctionPaymentConfigResponse toResponse(AuctionPaymentConfig config) {
        return AuctionPaymentConfigResponse.builder()
                .id(config.getId())
                .bankName(config.getBankName())
                .accountNumber(config.getAccountNumber())
                .accountHolderName(config.getAccountHolderName())
                .qrImageUrl(config.getQrImageUrl())
                .branchName(config.getBranchName())
                .transferNotePrefix(config.getTransferNotePrefix())
                .active(config.isActive())
                .createdAt(config.getCreatedAt())
                .updatedAt(config.getUpdatedAt())
                .build();
    }
}
