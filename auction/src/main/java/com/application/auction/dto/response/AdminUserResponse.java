package com.application.auction.dto.response;

import com.application.auction.enums.KycStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class AdminUserResponse {
    UUID id;
    String name;
    String role;
    KycStatus kycStatus;
    String accountStatus;
    String avatar;
    String email;
    String phone;
    String cccd;
    LocalDate dob;
    String address;
}
