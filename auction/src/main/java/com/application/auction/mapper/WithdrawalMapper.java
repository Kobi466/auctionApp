package com.application.auction.mapper;

import com.application.auction.dto.request.WithdrawalCreateRequest;
import com.application.auction.dto.response.WithdrawalResponse;
import com.application.auction.entity.WithdrawalRequest;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface WithdrawalMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "adminNote", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "requestedAt", ignore = true)
    @Mapping(target = "reviewedAt", ignore = true)
    @Mapping(target = "completedAt", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    WithdrawalRequest toWithdrawalRequest(WithdrawalCreateRequest request);

    @Mapping(target = "username", ignore = true)
    @Mapping(target = "userEmail", ignore = true)
    @Mapping(target = "userFullName", ignore = true)
    WithdrawalResponse toWithdrawalResponse(WithdrawalRequest withdrawalRequest);
}
