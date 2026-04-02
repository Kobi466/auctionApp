package com.application.auction.mapper;



import com.application.auction.dto.request.RoleRequest;
import com.application.auction.dto.response.RoleResponse;
import com.application.auction.entity.Role;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;


@Mapper(componentModel = "spring")
public interface RoleMapper {
    @Mapping(target =  "permissions", ignore = true) // bo qua phan set<permission> o entity role
    Role toRole(RoleRequest request);
    RoleResponse toRoleResponse(Role role);

}
