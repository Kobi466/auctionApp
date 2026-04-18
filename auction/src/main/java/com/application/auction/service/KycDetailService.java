package com.application.auction.service;

import com.application.auction.dto.request.KycDetailRequest;
import com.application.auction.dto.request.KycReviewRequest;
import com.application.auction.dto.response.KycDetailResponse;
import com.application.auction.entity.KycDetail;
import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.KycStatus;
import com.application.auction.exception.AppException;
import com.application.auction.repository.KycDetailRepository;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class KycDetailService {

    KycDetailRepository kycDetailRepository;
    UserRepository userRepository;
    ProfileRepository profileRepository;

    //Lấy KYC mới nhất của user đang đăng nhập
    @Transactional(readOnly = true)
    public KycDetailResponse getMyKycDetail() {
        User currentUser = getCurrentUser();
        KycDetail kycDetail = kycDetailRepository.findTopByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .orElseThrow(() -> new AppException(ErrorCode.KYC_DETAIL_NOT_FOUND));
        return toResponse(kycDetail);
    }

    //User gửi hoặc cập nhật thông tin KYC
    @Transactional
    public KycDetailResponse submitMyKyc(KycDetailRequest request) {
        User currentUser = getCurrentUser();

        String normalizedIdNumber = requireValue(request.getIdNumber());
        String normalizedFullName = requireInfoValue(request.getFullName());
        LocalDate dateOfBirth = requireDate(request.getDateOfBirth());
        String normalizedGender = requireInfoValue(request.getGender());
        String normalizedNationality = requireInfoValue(request.getNationality());
        String normalizedPlaceOfOrigin = requireInfoValue(request.getPlaceOfOrigin());
        String normalizedPlaceOfResidence = requireInfoValue(request.getPlaceOfResidence());
        String normalizedSelfie = requireValue(request.getSelfie());
        String normalizedFrontSide = requireValue(request.getFrontSide());
        String normalizedBackSide = requireValue(request.getBackSide());

        KycDetail existingDetail = kycDetailRepository.findTopByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .orElse(null);

        validateIdNumber(normalizedIdNumber, existingDetail == null ? null : existingDetail.getId());

        KycDetail kycDetail = existingDetail != null ? existingDetail : KycDetail.builder()
                .userId(currentUser.getId())
                .build();

        kycDetail.setIdNumber(normalizedIdNumber);
        kycDetail.setFullName(normalizedFullName);
        kycDetail.setDateOfBirth(dateOfBirth);
        kycDetail.setGender(normalizedGender);
        kycDetail.setNationality(normalizedNationality);
        kycDetail.setPlaceOfOrigin(normalizedPlaceOfOrigin);
        kycDetail.setPlaceOfResidence(normalizedPlaceOfResidence);
        kycDetail.setSelfie(normalizedSelfie);
        kycDetail.setFrontSide(normalizedFrontSide);
        kycDetail.setBackSide(normalizedBackSide);
        kycDetail.setStatus(KycStatus.PENDING);
        kycDetail.setRejectedReason(null);

        KycDetail savedDetail = kycDetailRepository.save(kycDetail);
        syncProfileKycStatus(currentUser.getId(), KycStatus.PENDING);
        return toResponse(savedDetail);
    }

    //Admin duyệt hoặc từ chối KYC
    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public KycDetailResponse reviewKyc(UUID kycDetailId, KycReviewRequest request) {
        KycDetail kycDetail = kycDetailRepository.findById(kycDetailId)
                .orElseThrow(() -> new AppException(ErrorCode.KYC_DETAIL_NOT_FOUND));

        KycStatus nextStatus = request.getStatus() == null ? KycStatus.PENDING : request.getStatus();
        String rejectedReason = normalize(request.getRejectedReason());

        if (nextStatus == KycStatus.REJECTED && rejectedReason == null) {
            throw new AppException(ErrorCode.KYC_REJECT_REASON_REQUIRED);
        }

        if (nextStatus != KycStatus.REJECTED) {
            rejectedReason = null;
        }

        kycDetail.setStatus(nextStatus);
        kycDetail.setRejectedReason(rejectedReason);

        KycDetail savedDetail = kycDetailRepository.save(kycDetail);
        syncProfileKycStatus(savedDetail.getUserId(), nextStatus);
        return toResponse(savedDetail);
    }

    //Check user đã KYC chưa trước khi cho đấu giá
    @Transactional(readOnly = true)
    public void ensureCurrentUserVerifiedForAuction() {
        User currentUser = getCurrentUser();
        KycDetail kycDetail = kycDetailRepository.findTopByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .orElseThrow(() -> new AppException(ErrorCode.KYC_VERIFICATION_REQUIRED));

        if (kycDetail.getStatus() != KycStatus.VERIFIED) {
            throw new AppException(ErrorCode.KYC_VERIFICATION_REQUIRED);
        }
    }

    //Kiểm tra CCCD có bị trùng không
    private void validateIdNumber(String idNumber, UUID currentKycId) {
        boolean exists = currentKycId == null
                ? kycDetailRepository.existsByIdNumber(idNumber)
                : kycDetailRepository.existsByIdNumberAndIdNot(idNumber, currentKycId);

        if (exists) {
            throw new AppException(ErrorCode.KYC_ID_NUMBER_ALREADY_EXISTS);
        }
    }
    //Đồng bộ trạng thái KYC sang bảng Profile
    private void syncProfileKycStatus(UUID userId, KycStatus status) {
        Profile profile = profileRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        profile.setKycStatus(status);
        profileRepository.save(profile);
    }

    //Lấy user đang đăng nhập từ Spring Security
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
    //Bắt buộc field phải có giá trị
    private String requireValue(String value) {
        String normalized = normalize(value);
        if (normalized == null) {
            throw new AppException(ErrorCode.KYC_DOCUMENT_REQUIRED);
        }
        return normalized;
    }

    private String requireInfoValue(String value) {
        String normalized = normalize(value);
        if (normalized == null) {
            throw new AppException(ErrorCode.KYC_INFORMATION_REQUIRED);
        }
        return normalized;
    }

    private LocalDate requireDate(LocalDate value) {
        if (value == null) {
            throw new AppException(ErrorCode.KYC_INFORMATION_REQUIRED);
        }
        return value;
    }

    //Chuẩn hóa dữ liệu input
    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private KycDetailResponse toResponse(KycDetail kycDetail) {
        return KycDetailResponse.builder()
                .id(kycDetail.getId())
                .userId(kycDetail.getUserId())
                .idNumber(kycDetail.getIdNumber())
                .fullName(kycDetail.getFullName())
                .dateOfBirth(kycDetail.getDateOfBirth())
                .gender(kycDetail.getGender())
                .nationality(kycDetail.getNationality())
                .placeOfOrigin(kycDetail.getPlaceOfOrigin())
                .placeOfResidence(kycDetail.getPlaceOfResidence())
                .selfie(kycDetail.getSelfie())
                .frontSide(kycDetail.getFrontSide())
                .backSide(kycDetail.getBackSide())
                .status(kycDetail.getStatus())
                .rejectedReason(kycDetail.getRejectedReason())
                .createdAt(kycDetail.getCreatedAt())
                .updatedAt(kycDetail.getUpdatedAt())
                .build();
    }
}
