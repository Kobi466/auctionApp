package com.application.auction.entity;

import com.application.auction.websocket.enums.AuctionRoomStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
@Table(
        name = "auction_rooms",
        indexes = {
                @Index(name = "idx_room_code", columnList = "roomCode"),
                @Index(name = "idx_status", columnList = "status")
        }
)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AuctionRoom {

    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(nullable = false, updatable = false, length = 36)
    UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false, unique = true)
    Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    User seller;

    @Column(nullable = false, unique = true, length = 60)
    String roomCode;

    String roomPassword;

    @Column(nullable = false)
    boolean isPrivate = false;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal startingPrice;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal currentPrice;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal minBidIncrement;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal depositAmount;

    @Column(nullable = false)
    Instant startTime;

    @Column(nullable = false)
    Instant endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    AuctionRoomStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "highest_bidder_id")
    User highestBidder;

    @OneToMany(mappedBy = "auctionRoom")
    List<Bid> bids;

    Integer participantCount = 0;

    Instant createdAt;

    Instant updatedAt;

    @Transient
    public BigDecimal getNextMinimumBid() {
        return currentPrice.add(minBidIncrement);
    }

    @PrePersist
    void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }

        if (currentPrice == null) {
            currentPrice = startingPrice;
        }

        Instant now = Instant.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}