package com.application.auction.mapper;

import com.application.auction.dto.request.UserCreationRequest;
import com.application.auction.dto.request.UserUpdateRequest;
import com.application.auction.dto.response.UserResponse;
import com.application.auction.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(UserCreationRequest userCreationRequest);
    UserResponse toUserResponse(User user);
    @Mapping(target = "roles", ignore = true) // bo qua roles
    void updateUser(@MappingTarget User user, UserUpdateRequest request);
}
