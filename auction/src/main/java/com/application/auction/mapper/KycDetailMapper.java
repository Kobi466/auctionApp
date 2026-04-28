package com.application.auction.mapper;

import com.application.auction.dto.request.KycDetailRequest;
import com.application.auction.dto.response.KycDetailResponse;
import com.application.auction.entity.KycDetail;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface KycDetailMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "rejectedReason", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    KycDetail toKycDetail(KycDetailRequest request);

    @Mapping(target = "email", source = "user.email")
    KycDetailResponse toKycDetailResponse(KycDetail kycDetail);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "rejectedReason", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateKycDetail(@MappingTarget KycDetail kycDetail, KycDetailRequest request);
}
