package com.application.auction.repository;

import com.application.auction.entity.AuctionRoom;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AuctionRepository extends JpaRepository<AuctionRoom, UUID> {

    /**
     * Finds an auction by its ID and applies a pessimistic write lock.
     * This is crucial for preventing race conditions during bidding. The database locks the
     * row for the duration of the transaction, forcing other transactions to wait,
     * thus ensuring that bids are processed sequentially and data remains consistent.
     *
     * @param id The ID of the auction to find.
     * @return An Optional containing the locked auction, if found.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM AuctionRoom a WHERE a.id = :id")
    Optional<AuctionRoom> findByIdForUpdate(UUID id);
}
