package com.application.auction.repository;

import com.application.auction.entity.AuctionRoom;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AuctionRoomRepository extends JpaRepository<AuctionRoom, UUID> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM AuctionRoom a WHERE a.id = :id")
    Optional<AuctionRoom> findByIdForUpdate(UUID id);

    @Query("""
            SELECT a.id
            FROM AuctionRoom a
            WHERE a.endTime <= :now
              AND a.status <> com.application.auction.websocket.enums.AuctionRoomStatus.CANCELLED
              AND a.winnerNotified = false
            """)
    List<UUID> findEndedRoomIdsPendingFinalization(Instant now);

    Optional<AuctionRoom> findByProductId(UUID productId);
    Optional<AuctionRoom> findByRoomCode(String roomCode);
    boolean existsByRoomCode(String roomCode);
    void deleteByProductId(UUID productId);
}
