package com.application.auction.mapper;

import com.application.auction.dto.response.ProfileResponse;
import com.application.auction.entity.Profile;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ProfileMapper {
    ProfileResponse toProfileResponse(Profile profile);
}
