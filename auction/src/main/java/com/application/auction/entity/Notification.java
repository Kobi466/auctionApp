package com.application.auction.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(nullable = false, updatable = false, length = 36)
    UUID id;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "user_id", nullable = false, length = 36)
    UUID userId;

    @Column(nullable = false, length = 200)
    String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    String message;

    @Column(nullable = false, length = 50)
    String type;

    @Builder.Default
    @Column(name = "is_read", nullable = false)
    boolean read = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    Instant createdAt;

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
    }
}
