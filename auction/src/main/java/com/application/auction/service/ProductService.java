package com.application.auction.service;

import com.application.auction.dto.request.ProductRequest;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Product;
import com.application.auction.entity.User;
import com.application.auction.enums.AuctionRoomStatus;
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
import java.util.Locale;
import java.util.Random;
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

        AuctionRoom auctionRoom = buildAuctionRoom(savedProduct.getId(), request);
        AuctionRoom savedRoom = auctionRoomRepository.save(auctionRoom);
        return toResponse(savedProduct, savedRoom);
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

        AuctionRoom auctionRoom = auctionRoomRepository.findByProductId(productId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        updateAuctionRoom(auctionRoom, request, productId);
        AuctionRoom savedRoom = auctionRoomRepository.save(auctionRoom);

        return toResponse(savedProduct, savedRoom);
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
        AuctionRoom auctionRoom = auctionRoomRepository.findByProductId(productId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        return toResponse(product, auctionRoom);
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getProducts() {
        return productRepository.findAll().stream()
                .map(product -> {
                    AuctionRoom auctionRoom = auctionRoomRepository.findByProductId(product.getId())
                            .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
                    return toResponse(product, auctionRoom);
                })
                .toList();
    }

    private ProductRequest sanitizeProductRequest(ProductRequest request) {
        return ProductRequest.builder()
                .name(requireText(request.getName(), ErrorCode.PRODUCT_NAME_REQUIRED))
                .subTitle(normalize(request.getSubTitle()))
                .brand(requireText(request.getBrand(), ErrorCode.PRODUCT_BRAND_REQUIRED))
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
                .status(request.getStatus() == null ? com.application.auction.enums.ProductStatus.DRAFT : request.getStatus())
                .minimumBid(request.getMinimumBid())
                .depositAmount(request.getDepositAmount())
                .auctionStartTime(request.getAuctionStartTime())
                .auctionEndTime(request.getAuctionEndTime())
                .build();
    }

    private AuctionRoom buildAuctionRoom(UUID productId, ProductRequest request) {
        validateAuctionRequest(request);
        return AuctionRoom.builder()
                .productId(productId)
                .roomCode("ROOM-" + productId)
                .roomPassword(generateRoomPassword())
                .minimumBid(request.getMinimumBid())
                .depositAmount(request.getDepositAmount())
                .startTime(request.getAuctionStartTime())
                .endTime(request.getAuctionEndTime())
                .status(resolveAuctionRoomStatus(request.getAuctionStartTime(), request.getAuctionEndTime()))
                .build();
    }

    private void updateAuctionRoom(AuctionRoom auctionRoom, ProductRequest request, UUID productId) {
        validateAuctionRequest(request);
        auctionRoom.setProductId(productId);
        auctionRoom.setRoomCode("ROOM-" + productId);
        if (auctionRoom.getRoomPassword() == null || auctionRoom.getRoomPassword().isBlank()) {
            auctionRoom.setRoomPassword(generateRoomPassword());
        }
        auctionRoom.setMinimumBid(request.getMinimumBid());
        auctionRoom.setDepositAmount(request.getDepositAmount());
        auctionRoom.setStartTime(request.getAuctionStartTime());
        auctionRoom.setEndTime(request.getAuctionEndTime());
        auctionRoom.setStatus(resolveAuctionRoomStatus(request.getAuctionStartTime(), request.getAuctionEndTime()));
    }

    private void validateAuctionRequest(ProductRequest request) {
        BigDecimal minimumBid = request.getMinimumBid();
        BigDecimal depositAmount = request.getDepositAmount();
        Instant startTime = request.getAuctionStartTime();
        Instant endTime = request.getAuctionEndTime();

        if (minimumBid == null || minimumBid.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.AUCTION_MINIMUM_BID_REQUIRED);
        }

        if (depositAmount == null || depositAmount.compareTo(minimumBid) < 0) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_INVALID);
        }

        if (startTime == null || endTime == null || !endTime.isAfter(startTime)) {
            throw new AppException(ErrorCode.AUCTION_SCHEDULE_INVALID);
        }
    }

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

    private String requireText(String value, ErrorCode errorCode) {
        String normalized = normalize(value);
        if (normalized == null) {
            throw new AppException(errorCode);
        }
        return normalized;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private User getCurrentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private ProductResponse toResponse(Product product, AuctionRoom auctionRoom) {
        ProductResponse response = productMapper.toProductResponse(product);
        response.setAuctionRoom(auctionRoomMapper.toAuctionRoomResponse(auctionRoom));
        return response;
    }

    private String generateRoomPassword() {
        String characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random random = new Random();
        StringBuilder builder = new StringBuilder(8);
        for (int index = 0; index < 8; index++) {
            builder.append(characters.charAt(random.nextInt(characters.length())));
        }
        return builder.toString().toUpperCase(Locale.ROOT);
    }

}
