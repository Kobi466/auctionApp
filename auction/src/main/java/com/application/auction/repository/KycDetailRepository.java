package com.application.auction.repository;

import com.application.auction.entity.KycDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface KycDetailRepository extends JpaRepository<KycDetail, UUID> {
    Optional<KycDetail> findTopByUserIdOrderByCreatedAtDesc(UUID userId);

    boolean existsByIdNumber(String idNumber);

    boolean existsByIdNumberAndIdNot(String idNumber, UUID id);
}
