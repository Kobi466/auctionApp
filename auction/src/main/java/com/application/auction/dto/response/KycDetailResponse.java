package com.application.auction.dto.response;

import com.application.auction.enums.KycStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class KycDetailResponse {
    UUID id;
    UUID userId;
    String idNumber;
    String fullName;
    LocalDate dateOfBirth;
    String gender;
    String nationality;
    String placeOfOrigin;
    String placeOfResidence;
    String selfie;
    String frontSide;
    String backSide;
    KycStatus status;
    String rejectedReason;
    Instant createdAt;
    Instant updatedAt;
}
