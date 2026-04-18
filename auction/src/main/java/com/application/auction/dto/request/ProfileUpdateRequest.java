package com.application.auction.dto.request;

import com.application.auction.enums.KycStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileUpdateRequest {
    String fullName;
    String email;
    String phoneNumber;
    String avatar;
    String bio;
    Boolean isWalletActive;
    KycStatus kycStatus;
    String preferences;
}
