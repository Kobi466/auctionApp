package com.application.auction.repository;

import com.application.auction.entity.Bid;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BidRepository extends JpaRepository<Bid, UUID> {
    List<Bid> findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(UUID auctionRoomId);

    long countByAuctionRoomId(UUID auctionRoomId);

    Optional<Bid> findTopByAuctionRoomIdOrderByAmountDescCreatedAtAsc(UUID auctionRoomId);

    Optional<Bid> findTopByAuctionRoomIdAndBidderIdOrderByTimestampDesc(UUID auctionRoomId, UUID bidderId);
}
