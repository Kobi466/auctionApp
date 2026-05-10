package com.application.auction.service;

import com.application.auction.dto.response.AuctionParticipantResponse;
import com.application.auction.entity.AuctionDeposit;
import com.application.auction.enums.AuctionDepositStatus;
import com.application.auction.repository.AuctionDepositRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
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
            response.setUserName(maskName(user.getUsername()));
            response.setUserEmail(user.getEmail());
        });
        profileRepository.findById(deposit.getUserId()).ifPresent(profile -> {
            response.setUserAvatar(profile.getAvatar());
            if (profile.getFullName() != null && !profile.getFullName().isBlank()) {
                response.setUserName(maskName(profile.getFullName()));
            }
            if (response.getUserEmail() == null || response.getUserEmail().isBlank()) {
                response.setUserEmail(profile.getEmail());
            }
        });
        return response;
    }

    private String maskName(String value) {
        if (value == null || value.isBlank()) {
            return "Nguoi dung";
        }
        String trimmed = value.trim();
        if (trimmed.length() <= 2) {
            return trimmed.charAt(0) + "***";
        }
        return trimmed.substring(0, Math.min(4, trimmed.length())) + "***";
    }
}
