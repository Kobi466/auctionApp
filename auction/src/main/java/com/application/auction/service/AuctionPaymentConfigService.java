package com.application.auction.service;

import com.application.auction.dto.request.AuctionPaymentConfigRequest;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.entity.AuctionPaymentConfig;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionPaymentConfigMapper;
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
    AuctionPaymentConfigMapper auctionPaymentConfigMapper;

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AuctionPaymentConfigResponse upsert(AuctionPaymentConfigRequest request) {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findById(1L)
                .orElse(AuctionPaymentConfig.builder().id(1L).build());
        AuctionPaymentConfigRequest sanitizedRequest = AuctionPaymentConfigRequest.builder()
                .bankName(requireText(request.getBankName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .accountNumber(requireText(request.getAccountNumber(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .accountHolderName(requireText(request.getAccountHolderName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .qrImageUrl(requireText(request.getQrImageUrl(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .branchName(normalize(request.getBranchName()))
                .transferNotePrefix(normalize(request.getTransferNotePrefix()))
                .active(request.getActive() == null || request.getActive())
                .build();

        auctionPaymentConfigMapper.updateAuctionPaymentConfig(config, sanitizedRequest);
        return auctionPaymentConfigMapper.toAuctionPaymentConfigResponse(auctionPaymentConfigRepository.save(config));
    }

    @Transactional(readOnly = true)
    public AuctionPaymentConfigResponse getActive() {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findFirstByActiveTrue()
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        return auctionPaymentConfigMapper.toAuctionPaymentConfigResponse(config);
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

}
