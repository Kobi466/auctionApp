package com.application.auction.repository;

import com.application.auction.entity.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;


public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
    Optional<User> findByEmail(String email);
    @EntityGraph(attributePaths = {"roles", "roles.permissions"})
    Optional<User> findWithRolesByEmail(String email);
    @EntityGraph(attributePaths = {"roles", "roles.permissions"})
    Optional<User> findWithRolesByUsername(String username);
    Optional<User> findByUsername(String username);
}
