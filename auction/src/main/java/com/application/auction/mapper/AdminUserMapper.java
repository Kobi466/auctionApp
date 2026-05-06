package com.application.auction.mapper;

import com.application.auction.dto.response.AdminUserResponse;
import com.application.auction.entity.KycDetail;
import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.enums.KycStatus;
import org.mapstruct.Mapper;

import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface AdminUserMapper {
    default AdminUserResponse toAdminUserResponse(User user, Profile profile, KycDetail kycDetail) {
        String email = profile == null ? user.getEmail() : profile.getEmail();
        String phone = profile == null ? user.getPhone() : profile.getPhoneNumber();
        String name = profile == null ? email : normalizeName(profile.getFullName(), email);
        KycStatus kycStatus = profile == null
                ? (kycDetail == null ? KycStatus.PENDING : kycDetail.getStatus())
                : profile.getKycStatus();

        return AdminUserResponse.builder()
                .id(user.getId())
                .name(name)
                .role(formatRoles(user))
                .kycStatus(kycStatus)
                .accountStatus(user.isActive() ? "ACTIVE" : "LOCKED")
                .avatar(profile == null ? null : profile.getAvatar())
                .email(email)
                .phone(phone)
                .cccd(kycDetail == null ? null : kycDetail.getIdNumber())
                .dob(kycDetail == null ? null : kycDetail.getDateOfBirth())
                .address(kycDetail == null ? null : kycDetail.getPlaceOfResidence())
                .build();
    }

    private String normalizeName(String fullName, String fallback) {
        return fullName == null || fullName.isBlank() ? fallback : fullName;
    }

    private String formatRoles(User user) {
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            return "USER";
        }

        return user.getRoles().stream()
                .map(role -> role.getName() == null ? "" : role.getName())
                .filter(name -> !name.isBlank())
                .collect(Collectors.joining(", "));
    }
}
