package com.application.auction.repository;

import com.application.auction.entity.AuctionRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AuctionRoomRepository extends JpaRepository<AuctionRoom, UUID> {
    Optional<AuctionRoom> findByProductId(UUID productId);
    Optional<AuctionRoom> findByRoomCode(String roomCode);
    boolean existsByRoomCode(String roomCode);
    void deleteByProductId(UUID productId);
}
