package com.application.auction.entity;


import com.application.auction.enums.KycStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

@Entity
@Table(name = "profiles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Profile {
    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "user_id", nullable = false, updatable = false, length = 36)
    UUID userId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            insertable = false,
            updatable = false,
            foreignKey = @ForeignKey(name = "fk_profile_user")
    )
    User user;

    @Column(name = "full_name", unique = true)
    String fullName;

    @Column(nullable = false, unique = true)
    String email;

    @Column(name = "phone_number", unique = true)
    String phoneNumber;

    String avatar;

    String bio;

    @Column(name = "is_wallet_active", nullable = false)
    Boolean isWalletActive;

    @Enumerated(EnumType.STRING)
    @Column(name = "kyc_status", nullable = false, length = 30)
    KycStatus kycStatus;

    @Column(columnDefinition = "TEXT")
    String preferences;
}
