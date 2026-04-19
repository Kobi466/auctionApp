package com.application.auction.dto.response;

import com.application.auction.enums.ProductStatus;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductResponse {
    UUID id;
    String name;
    String subTitle;
    String brand;
    String description;
    String shortDescription;
    List<String> imageUrls;
    String mainImageUrl;
    String categoryId;
    UUID createdByAdminId;
    List<String> tags;
    String authenticity;
    String provenance;
    Map<String, Object> attributes;
    Integer rarityRank;
    ProductStatus status;
    Instant createdAt;
    Instant updatedAt;
    AuctionRoomResponse auctionRoom;
}
