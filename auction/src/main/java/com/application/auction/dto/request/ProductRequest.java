package com.application.auction.dto.request;

import com.application.auction.enums.ProductStatus;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.util.List;
import java.util.Map;
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductRequest {
    String name;
    String subTitle;
    String brand;
    String description;
    String shortDescription;
    List<String> imageUrls;
    String mainImageUrl;
    String categoryId;
    List<String> tags;
    String authenticity;
    String provenance;
    Map<String, Object> attributes;
    Integer rarityRank;
    ProductStatus status;
}
