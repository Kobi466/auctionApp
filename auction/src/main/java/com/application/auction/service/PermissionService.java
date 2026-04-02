package com.application.auction.service;


import com.application.auction.dto.request.PermissionRequest;
import com.application.auction.dto.response.PermissionResponse;
import com.application.auction.entity.Permission;
import com.application.auction.mapper.PermissionMapper;
import com.application.auction.repository.PermissionRepository;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class PermissionService {
    PermissionRepository permissionRepository;
    PermissionMapper permissionMapper;
   public PermissionResponse create(PermissionRequest request) {
        Permission permission = permissionMapper.toPermission(request);
        permission = permissionRepository.save(permission);
        return permissionMapper.toPermissionResponse(permission);
    }

    public List<PermissionResponse> getAll() {
      var permissions = permissionRepository.findAll();
      return permissions.stream().map(permissionMapper::toPermissionResponse).toList();
    }

     public void delete(String permission) {
        permissionRepository.deleteById(permission);
    }
}
