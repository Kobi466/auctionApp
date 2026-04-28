package com.application.auction.entity;

import com.application.auction.enums.KycStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "kyc_details")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class KycDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(nullable = false, updatable = false, length = 36)
    UUID id;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "user_id", nullable = false, length = 36)
    UUID userId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            insertable = false,
            updatable = false,
            foreignKey = @ForeignKey(name = "fk_kyc_detail_user")
    )

    User user;

    @Column(name = "id_number", nullable = false, unique = true)
    String idNumber;

    @Column(name = "full_name", nullable = false)
    String fullName;

    @Column(name = "date_of_birth", nullable = false)
    LocalDate dateOfBirth;

    @Column(nullable = false, length = 20)
    String gender;

    @Column(nullable = false, length = 100)
    String nationality;

    @Column(name = "place_of_origin", nullable = false, columnDefinition = "TEXT")
    String placeOfOrigin;

    @Column(name = "place_of_residence", nullable = false, columnDefinition = "TEXT")
    String placeOfResidence;

    @Column(nullable = false, columnDefinition = "LONGTEXT")
    String selfie;

    @Column(name = "front_side", nullable = false, columnDefinition = "LONGTEXT")
    String frontSide;

    @Column(name = "back_side", nullable = false, columnDefinition = "LONGTEXT")
    String backSide;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    KycStatus status;

    @Column(name = "rejected_reason", columnDefinition = "TEXT")
    String rejectedReason;

    @Column(name = "created_at", nullable = false, updatable = false)
    Instant createdAt;

    @Column(name = "updated_at")
    Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}
