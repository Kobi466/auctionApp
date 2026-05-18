package com.application.auction.dto.request;

import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class AdminWinnerRankActionRequest {
    Integer rank;
    Boolean sendEmail;
}
