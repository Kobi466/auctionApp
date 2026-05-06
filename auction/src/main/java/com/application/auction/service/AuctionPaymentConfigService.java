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

import java.util.List;

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
        return saveConfig(config, request);
    }

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public List<AuctionPaymentConfigResponse> getAll() {
        return auctionPaymentConfigRepository.findAll().stream()
                .map(auctionPaymentConfigMapper::toAuctionPaymentConfigResponse)
                .toList();
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AuctionPaymentConfigResponse create(AuctionPaymentConfigRequest request) {
        return saveConfig(AuctionPaymentConfig.builder().build(), request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public AuctionPaymentConfigResponse update(Long id, AuctionPaymentConfigRequest request) {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        return saveConfig(config, request);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(Long id) {
        AuctionPaymentConfig config = auctionPaymentConfigRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED));
        auctionPaymentConfigRepository.delete(config);
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

    private AuctionPaymentConfigResponse saveConfig(
            AuctionPaymentConfig config,
            AuctionPaymentConfigRequest request
    ) {
        AuctionPaymentConfigRequest sanitizedRequest = AuctionPaymentConfigRequest.builder()
                .bankName(requireText(request.getBankName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .accountNumber(requireText(request.getAccountNumber(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .accountHolderName(requireText(request.getAccountHolderName(), ErrorCode.AUCTION_PAYMENT_CONFIG_REQUIRED))
                .qrImageUrl(normalize(request.getQrImageUrl()) == null ? "" : normalize(request.getQrImageUrl()))
                .branchName(normalize(request.getBranchName()))
                .transferNotePrefix(normalize(request.getTransferNotePrefix()))
                .active(request.getActive() == null || request.getActive())
                .build();

        if (sanitizedRequest.getActive() == null || sanitizedRequest.getActive()) {
            auctionPaymentConfigRepository.findAll().forEach(existing -> {
                if (config.getId() == null || !existing.getId().equals(config.getId())) {
                    existing.setActive(false);
                    auctionPaymentConfigRepository.save(existing);
                }
            });
        }

        auctionPaymentConfigMapper.updateAuctionPaymentConfig(config, sanitizedRequest);
        return auctionPaymentConfigMapper.toAuctionPaymentConfigResponse(auctionPaymentConfigRepository.save(config));
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
