package com.application.auction.service;


import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.enums.KycStatus;
import com.application.auction.repository.ProfileRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProfileService {

    ProfileRepository profileRepository;

    @Transactional
    public Profile ensureProfileExists(User user) {
        return profileRepository.findById(user.getId())
                .map(existingProfile -> syncProfile(existingProfile, user))
                .orElseGet(() -> profileRepository.findByEmail(user.getEmail())
                        .map(existingProfile -> attachProfileToUser(existingProfile, user))
                        .orElseGet(() -> createProfile(user)));
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
}
