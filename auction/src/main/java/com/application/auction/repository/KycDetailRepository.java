package com.application.auction.repository;

import com.application.auction.entity.KycDetail;
import com.application.auction.enums.KycStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface KycDetailRepository extends JpaRepository<KycDetail, UUID> {
    Optional<KycDetail> findTopByUserIdOrderByCreatedAtDesc(UUID userId);

    @EntityGraph(attributePaths = {"user"})
    List<KycDetail> findAllByOrderByUpdatedAtDesc();
    boolean existsByIdNumber(String idNumber);
    boolean existsByIdNumberAndIdNot(String idNumber, UUID id);
    long countByStatus(KycStatus status);
}
