package com.application.auction.mapper;


import com.application.auction.dto.request.PermissionRequest;
import com.application.auction.dto.response.PermissionResponse;
import com.application.auction.entity.Permission;
import org.mapstruct.Mapper;


@Mapper(componentModel = "spring")
public interface PermissionMapper {
    Permission toPermission(PermissionRequest request);

    PermissionResponse toPermissionResponse(Permission permission);

}
