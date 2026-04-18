package com.application.auction.service;


import com.application.auction.dto.request.ProfileUpdateRequest;
import com.application.auction.dto.response.ProfileResponse;
import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.KycStatus;
import com.application.auction.exception.AppException;
import com.application.auction.repository.ProfileRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProfileService {

    ProfileRepository profileRepository;
    UserRepository userRepository;

    @Transactional
    public Profile ensureProfileExists(User user) {
        return profileRepository.findById(user.getId())
                .map(existingProfile -> syncProfile(existingProfile, user))
                .orElseGet(() -> profileRepository.findByEmail(user.getEmail())
                        .map(existingProfile -> attachProfileToUser(existingProfile, user))
                        .orElseGet(() -> createProfile(user)));
    }

    @Transactional(readOnly = true)
    public ProfileResponse getMyProfile() {
        User currentUser = getCurrentUser();
        Profile profile = ensureProfileExists(currentUser);
        return toProfileResponse(profile);
    }

    @Transactional
    public ProfileResponse updateMyProfile(ProfileUpdateRequest request) {
        User currentUser = getCurrentUser();
        Profile profile = ensureProfileExists(currentUser);

        String normalizedEmail = normalize(request.getEmail());
        String normalizedFullName = normalize(request.getFullName());
        String normalizedPhoneNumber = normalize(request.getPhoneNumber());
        String normalizedAvatar = normalize(request.getAvatar());
        String normalizedBio = normalize(request.getBio());
        String normalizedPreferences = normalize(request.getPreferences());

        if (normalizedEmail != null && !normalizedEmail.equals(profile.getEmail())) {
            if (userRepository.existsByEmail(normalizedEmail)
                    || profileRepository.existsByEmailAndUserIdNot(normalizedEmail, profile.getUserId())) {
                throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);
            }
            currentUser.setEmail(normalizedEmail);
            currentUser.setUsername(normalizedEmail);
            profile.setEmail(normalizedEmail);
        }

        if (normalizedFullName != null && !normalizedFullName.equals(profile.getFullName())) {
            if (profileRepository.existsByFullNameAndUserIdNot(normalizedFullName, profile.getUserId())) {
                throw new AppException(ErrorCode.FULL_NAME_ALREADY_EXISTS);
            }
            profile.setFullName(normalizedFullName);
        }

        if (normalizedPhoneNumber != null && !normalizedPhoneNumber.equals(profile.getPhoneNumber())) {
            if (profileRepository.existsByPhoneNumberAndUserIdNot(normalizedPhoneNumber, profile.getUserId())) {
                throw new AppException(ErrorCode.PHONE_NUMBER_ALREADY_EXISTS);
            }
            profile.setPhoneNumber(normalizedPhoneNumber);
        }

        if (request.getFullName() != null && normalizedFullName == null) {
            profile.setFullName(null);
        }
        if (request.getPhoneNumber() != null && normalizedPhoneNumber == null) {
            profile.setPhoneNumber(null);
        }
        if (request.getAvatar() != null) {
            profile.setAvatar(normalizedAvatar);
        }
        if (request.getBio() != null) {
            profile.setBio(normalizedBio);
        }
        if (request.getPreferences() != null) {
            profile.setPreferences(normalizedPreferences == null ? "{}" : normalizedPreferences);
        }
        if (request.getIsWalletActive() != null) {
            profile.setIsWalletActive(request.getIsWalletActive());
        }
        if (request.getKycStatus() != null) {
            profile.setKycStatus(request.getKycStatus());
        }

        userRepository.save(currentUser);
        Profile savedProfile = profileRepository.save(profile);
        return toProfileResponse(savedProfile);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private Profile syncProfile(Profile profile, User user) {
        boolean changed = false;

        if (profile.getEmail() == null || !profile.getEmail().equals(user.getEmail())) {
            profile.setEmail(user.getEmail());
            changed = true;
        }
        if (profile.getIsWalletActive() == null) {
            profile.setIsWalletActive(false);
            changed = true;
        }
        if (profile.getKycStatus() == null) {
            profile.setKycStatus(KycStatus.PENDING);
            changed = true;
        }
        if (profile.getPreferences() == null || profile.getPreferences().isBlank()) {
            profile.setPreferences("{}");
            changed = true;
        }

        return changed ? profileRepository.save(profile) : profile;
    }

    private Profile createProfile(User user) {
        return profileRepository.save(Profile.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .isWalletActive(false)
                .kycStatus(KycStatus.PENDING)
                .preferences("{}")
                .build());
    }

    private Profile attachProfileToUser(Profile profile, User user) {
        if (profile.getUserId().equals(user.getId())) {
            return syncProfile(profile, user);
        }

        Profile migratedProfile = Profile.builder()
                .userId(user.getId())
                .fullName(profile.getFullName())
                .email(user.getEmail())
                .phoneNumber(profile.getPhoneNumber())
                .avatar(profile.getAvatar())
                .bio(profile.getBio())
                .isWalletActive(profile.getIsWalletActive() != null ? profile.getIsWalletActive() : false)
                .kycStatus(profile.getKycStatus() != null ? profile.getKycStatus() : KycStatus.PENDING)
                .preferences(profile.getPreferences() == null || profile.getPreferences().isBlank() ? "{}" : profile.getPreferences())
                .build();

        profileRepository.delete(profile);
        return profileRepository.save(migratedProfile);
    }

    private ProfileResponse toProfileResponse(Profile profile) {
        return ProfileResponse.builder()
                .userId(profile.getUserId())
                .fullName(profile.getFullName())
                .email(profile.getEmail())
                .phoneNumber(profile.getPhoneNumber())
                .avatar(profile.getAvatar())
                .bio(profile.getBio())
                .isWalletActive(profile.getIsWalletActive())
                .kycStatus(profile.getKycStatus())
                .preferences(profile.getPreferences())
                .build();
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
