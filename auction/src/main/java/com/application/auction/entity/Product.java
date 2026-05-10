package com.application.auction.entity;

import com.application.auction.converter.MapJsonConverter;
import com.application.auction.converter.StringListJsonConverter;
import com.application.auction.enums.ProductStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
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

import java.time.Instant;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "products")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Product {
    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(nullable = false, updatable = false, length = 36)
    UUID id;

    @Column(nullable = false)
    String name;

    String subTitle;

    @Column(nullable = false)
    String brand;

    @Column(nullable = false, precision = 19, scale = 2)
    BigDecimal startingPrice;

    @Lob
    String description;

    @Lob
    String shortDescription;

    @Lob
    @Convert(converter = StringListJsonConverter.class)
    @Column(name = "image_urls", columnDefinition = "LONGTEXT")
    List<String> imageUrls;

    String mainImageUrl;

    @Column(nullable = false)
    String categoryId;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "created_by_admin_id", nullable = false, length = 36)
    UUID createdByAdminId;

    @Convert(converter = StringListJsonConverter.class)
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    List<String> tags;

    String authenticity;

    String provenance;

    @Convert(converter = MapJsonConverter.class)
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    Map<String, Object> attributes;

    Integer rarityRank;

    Instant plannedStartTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    ProductStatus status;

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
