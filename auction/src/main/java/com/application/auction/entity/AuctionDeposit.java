package com.application.auction.entity;

import com.application.auction.enums.AuctionDepositStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
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
import java.util.UUID;

@Entity
@Table(name = "auction_deposits")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AuctionDeposit {
    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(nullable = false, updatable = false, length = 36)
    UUID id;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "auction_room_id", nullable = false, length = 36)
    UUID auctionRoomId;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "product_id", nullable = false, length = 36)
    UUID productId;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "user_id", nullable = false, length = 36)
    UUID userId;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal requiredAmount;

    @Column(nullable = false, unique = true, length = 120)
    String transferContent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    AuctionDepositStatus status;

    String adminNote;

    String userNote;

    Instant paymentSubmittedAt;

    Instant approvedAt;

    @Column(nullable = false, updatable = false)
    Instant createdAt;

    Instant updatedAt;

    @PrePersist
    void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
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
