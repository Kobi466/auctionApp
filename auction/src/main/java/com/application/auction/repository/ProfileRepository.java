package com.application.auction.repository;

import com.application.auction.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {
    Optional<Profile> findByEmail(String email);
    boolean existsByEmailAndUserIdNot(String email, UUID userId);
    boolean existsByFullNameAndUserIdNot(String fullName, UUID userId);
    boolean existsByPhoneNumberAndUserIdNot(String phoneNumber, UUID userId);
}
