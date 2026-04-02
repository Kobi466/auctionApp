package com.application.auction.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class LoginResponse {
    String accessToken;
    String refreshToken;
    String tokenType;
    long accessTokenExpiresIn;
    long refreshTokenExpiresIn;
    boolean authenticated;
}
