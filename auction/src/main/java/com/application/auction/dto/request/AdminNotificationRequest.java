package com.application.auction.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class AdminNotificationRequest {
    @NotBlank
    @Size(max = 200)
    String title;

    @NotBlank
    String message;

    String type;
}
