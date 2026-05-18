package com.application.auction.service;

import com.application.auction.dto.response.AuctionParticipantResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.util.PrivacyMaskingUtil;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

//dăng ký đấu giá, status, quyền vào phòng.
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class AuctionRoomParticipantService {
    @Autowired
    AuctionDepositRepository auctionDepositRepository;
    UserRepository userRepository;
    ProfileRepository profileRepository;

    @Transactional(readOnly = true)
    public List<AuctionParticipantResponse> getApprovedParticipants(UUID roomId) {
        return auctionDepositRepository
                .findByAuctionRoomIdAndStatus(roomId, AuctionDepositStatus.APPROVED)
                .stream()
                .map(this::toParticipantResponse)
                .toList();
    }

    private AuctionParticipantResponse toParticipantResponse(AuctionDeposit deposit) {
        AuctionParticipantResponse response = AuctionParticipantResponse.builder()
                .userId(deposit.getUserId())
                .build();
        userRepository.findById(deposit.getUserId()).ifPresent(user -> {
            response.setUserName(PrivacyMaskingUtil.maskDisplayName(user.getUsername()));
            response.setUserEmail(PrivacyMaskingUtil.maskEmail(user.getEmail()));
        });
        profileRepository.findById(deposit.getUserId()).ifPresent(profile -> {
            response.setUserAvatar(profile.getAvatar());
            if (profile.getFullName() != null && !profile.getFullName().isBlank()) {
                response.setUserName(PrivacyMaskingUtil.maskDisplayName(profile.getFullName()));
            }
            if (response.getUserEmail() == null || response.getUserEmail().isBlank()) {
                response.setUserEmail(PrivacyMaskingUtil.maskEmail(profile.getEmail()));
            }
        });
        return response;
    }
}
