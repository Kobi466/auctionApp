package com.application.auction.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
@NoArgsConstructor
@AllArgsConstructor
@Data
public class UserResponse {
    String id;
    String email;
    Set<RoleResponse> roles;
    Boolean isActive;
}
