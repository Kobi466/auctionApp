package com.application.auction.dto.request;

import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class AdminUserStatusRequest {
    Boolean active;
    String reason;
}
