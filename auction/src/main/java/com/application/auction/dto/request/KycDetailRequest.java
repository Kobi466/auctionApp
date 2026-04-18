package com.application.auction.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class KycDetailRequest {
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
}
