package com.application.auction.repository;

import com.application.auction.entity.AuctionDeposit;
import com.application.auction.enums.AuctionDepositStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AuctionDepositRepository extends JpaRepository<AuctionDeposit, UUID> {
    Optional<AuctionDeposit> findTopByAuctionRoomIdAndUserIdOrderByCreatedAtDesc(UUID auctionRoomId, UUID userId);

    List<AuctionDeposit> findByStatus(AuctionDepositStatus status);
}
