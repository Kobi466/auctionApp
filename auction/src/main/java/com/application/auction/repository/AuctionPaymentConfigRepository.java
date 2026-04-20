package com.application.auction.repository;

import com.application.auction.entity.AuctionPaymentConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AuctionPaymentConfigRepository extends JpaRepository<AuctionPaymentConfig, Long> {
    Optional<AuctionPaymentConfig> findFirstByActiveTrue();
}
