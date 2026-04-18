package com.application.auction.dto.response;

import com.application.auction.enums.KycStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileResponse {
    UUID userId;
    String fullName;
    String email;
    String phoneNumber;
    String avatar;
    String bio;
    Boolean isWalletActive;
    KycStatus kycStatus;
    String preferences;
}
