package com.application.auction.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
@NoArgsConstructor
@AllArgsConstructor
@Data
public class RoleResponse {
    String roleName;
    String description;
    Set<PermissionResponse> permissions;
}
