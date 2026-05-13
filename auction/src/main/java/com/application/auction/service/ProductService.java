package com.application.auction.service;

import com.application.auction.dto.request.ProductRequest;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Product;
import com.application.auction.entity.User;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.mapper.ProductMapper;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProductService {

    ProductRepository productRepository;
    AuctionRoomRepository auctionRoomRepository;
    UserRepository userRepository;
    ProductMapper productMapper;
    AuctionRoomMapper auctionRoomMapper;

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse createProduct(ProductRequest request) {
        Product product = productMapper.toProduct(sanitizeProductRequest(request));
        product.setCreatedByAdminId(getCurrentAdmin().getId());
        Product savedProduct = productRepository.save(product);
        return toResponse(savedProduct);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse updateProduct(UUID productId, ProductRequest request) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));

        ProductRequest sanitizedRequest = sanitizeProductRequest(request);
        productMapper.updateProduct(product, sanitizedRequest);
        product.setCreatedByAdminId(getCurrentAdmin().getId());
        Product savedProduct = productRepository.save(product);
        syncAuctionRoomMinimumBid(savedProduct);

        return toResponse(savedProduct);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteProduct(UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        auctionRoomRepository.deleteByProductId(product.getId());
        productRepository.delete(product);
    }

    @Transactional(readOnly = true)
    public ProductResponse getProduct(UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        return toResponse(product);
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getProducts() {
        return productRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    private ProductRequest sanitizeProductRequest(ProductRequest request) {
        return ProductRequest.builder()
                .name(requireText(request.getName(), ErrorCode.PRODUCT_NAME_REQUIRED))
                .subTitle(normalize(request.getSubTitle()))
                .brand(requireText(request.getBrand(), ErrorCode.PRODUCT_BRAND_REQUIRED))
                .startingPrice(requirePositiveAmount(request.getStartingPrice()))
                .description(normalize(request.getDescription()))
                .shortDescription(normalize(request.getShortDescription()))
                .imageUrls(requireImageUrls(request.getImageUrls()))
                .mainImageUrl(normalize(request.getMainImageUrl()))
                .categoryId(requireText(request.getCategoryId(), ErrorCode.PRODUCT_CATEGORY_REQUIRED))
                .tags(request.getTags() == null ? List.of() : request.getTags().stream()
                        .map(this::normalize)
                        .filter(value -> value != null)
                        .toList())
                .authenticity(normalize(request.getAuthenticity()))
                .provenance(normalize(request.getProvenance()))
                .attributes(request.getAttributes() == null ? java.util.Map.of() : request.getAttributes())
                .rarityRank(request.getRarityRank())
                .plannedStartTime(request.getPlannedStartTime())
                .status(request.getStatus() == null ? com.application.auction.enums.ProductStatus.DRAFT : request.getStatus())
                .build();
    }

    //validate image urls
    private List<String> requireImageUrls(List<String> imageUrls) {
        if (imageUrls == null) {
            throw new AppException(ErrorCode.PRODUCT_IMAGES_REQUIRED);
        }

        List<String> normalizedImages = imageUrls.stream()
                .map(this::normalize)
                .filter(value -> value != null)
                .toList();

        if (normalizedImages.isEmpty()) {
            throw new AppException(ErrorCode.PRODUCT_IMAGES_REQUIRED);
        }
        return normalizedImages;
    }
    //validate text
    private String requireText(String value, ErrorCode errorCode) {
        String normalized = normalize(value);
        if (normalized == null) {
            throw new AppException(errorCode);
        }
        return normalized;
    }
    //validate positive amount
    private BigDecimal requirePositiveAmount(BigDecimal value) {
        if (value == null || value.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.AUCTION_MINIMUM_BID_REQUIRED);
        }
        return value;
    }
    //normalize string (làm sạch)
    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
    //get current admin
    private User getCurrentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
    //convert product to response
    private ProductResponse toResponse(Product product) {
        ProductResponse response = productMapper.toProductResponse(product);
        auctionRoomRepository.findByProductId(product.getId())
                .map(this::applyCurrentAuctionRoomStatus)
                .map(auctionRoomMapper::toAuctionRoomResponse)
                .ifPresent(response::setAuctionRoom);
        return response;
    }
    //sync auction room minimum bid
    private void syncAuctionRoomMinimumBid(Product product) {
        auctionRoomRepository.findByProductId(product.getId()).ifPresent(room -> {
            room.setStartingPrice(product.getStartingPrice());
            auctionRoomRepository.save(room);
        });
    }
    //cập nhật trạng thái phòng đấu giá
    private AuctionRoom applyCurrentAuctionRoomStatus(AuctionRoom auctionRoom) {
        auctionRoom.setStatus(resolveAuctionRoomStatus(
                auctionRoom.getStartTime(),
                auctionRoom.getEndTime()
        ));
        return auctionRoom;
    }
    //xác định trạng thái phòng đấu giá
    private AuctionRoomStatus resolveAuctionRoomStatus(Instant startTime, Instant endTime) {
        Instant now = Instant.now();
        if (now.isBefore(startTime)) {
            return AuctionRoomStatus.SCHEDULED;
        }
        if (now.isAfter(endTime)) {
            return AuctionRoomStatus.CLOSED;
        }
        return AuctionRoomStatus.LIVE;
    }

}
