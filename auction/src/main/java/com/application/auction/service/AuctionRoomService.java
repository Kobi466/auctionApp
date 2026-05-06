package com.application.auction.service;

import com.application.auction.dto.request.AuctionRoomRequest;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Product;
import com.application.auction.enums.AuctionRoomStatus;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.ProductStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.mapper.ProductMapper;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.ProductRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
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
public class AuctionRoomService {

    AuctionRoomRepository auctionRoomRepository;
    ProductRepository productRepository;
    AuctionRoomMapper auctionRoomMapper;
    ProductMapper productMapper;

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse createAuctionRoom(AuctionRoomRequest request) {
        AuctionRoomRequest sanitizedRequest = sanitizeAuctionRoomRequest(request);
        Product product = productRepository.findById(sanitizedRequest.getProductId())
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));

        if (auctionRoomRepository.findByProductId(product.getId()).isPresent()) {
            throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_EXISTS);
        }

        AuctionRoom auctionRoom = auctionRoomMapper.toAuctionRoom(sanitizedRequest);
        auctionRoom.setMinimumBid(product.getStartingPrice());
        applyAuctionRoomBusinessFields(auctionRoom);
        AuctionRoom savedRoom = auctionRoomRepository.save(auctionRoom);
        product.setStatus(resolveProductStatus(savedRoom.getStatus()));
        Product savedProduct = productRepository.save(product);
        return toProductResponse(savedProduct, savedRoom);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse updateAuctionRoom(UUID roomId, AuctionRoomRequest request) {
        AuctionRoom auctionRoom = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        AuctionRoomRequest sanitizedRequest = sanitizeAuctionRoomRequest(request);
        Product product = productRepository.findById(sanitizedRequest.getProductId())
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));

        auctionRoomRepository.findByProductId(product.getId())
                .filter(existingRoom -> !existingRoom.getId().equals(roomId))
                .ifPresent(existingRoom -> {
                    throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_EXISTS);
                });

        UUID previousProductId = auctionRoom.getProductId();
        auctionRoomMapper.updateAuctionRoom(auctionRoom, sanitizedRequest);
        auctionRoom.setMinimumBid(product.getStartingPrice());
        applyAuctionRoomBusinessFields(auctionRoom);
        AuctionRoom savedRoom = auctionRoomRepository.save(auctionRoom);
        resetPreviousProductStatus(previousProductId, product.getId());
        product.setStatus(resolveProductStatus(savedRoom.getStatus()));
        Product savedProduct = productRepository.save(product);
        return toProductResponse(savedProduct, savedRoom);
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getProductsWithAuctionRooms() {
        return auctionRoomRepository.findAll().stream()
                .map(room -> {
                    applyCurrentAuctionRoomStatus(room);
                    Product product = productRepository.findById(room.getProductId())
                            .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
                    return toProductResponse(product, room);
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public AuctionRoomResponse getAuctionRoom(UUID roomId) {
        AuctionRoom auctionRoom = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        applyCurrentAuctionRoomStatus(auctionRoom);
        return auctionRoomMapper.toAuctionRoomResponse(auctionRoom);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse cancelAuctionRoom(UUID roomId) {
        AuctionRoom auctionRoom = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        if (auctionRoom.getStatus() == AuctionRoomStatus.CLOSED
                || auctionRoom.getStatus() == AuctionRoomStatus.CANCELLED) {
            throw new AppException(ErrorCode.AUCTION_SCHEDULE_INVALID);
        }

        auctionRoom.setStatus(AuctionRoomStatus.CANCELLED);
        AuctionRoom savedRoom = auctionRoomRepository.save(auctionRoom);
        Product product = productRepository.findById(savedRoom.getProductId())
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        product.setStatus(ProductStatus.CANCELLED);
        Product savedProduct = productRepository.save(product);
        return toProductResponse(savedProduct, savedRoom);
    }

    private void applyAuctionRoomBusinessFields(AuctionRoom auctionRoom) {
        if (auctionRoom.getRoomCode() == null || auctionRoom.getRoomCode().isBlank()
                || auctionRoom.getRoomCode().startsWith("ROOM-")) {
            auctionRoom.setRoomCode(generateNumericRoomCode());
        }
        if (auctionRoom.getRoomPassword() == null || auctionRoom.getRoomPassword().isBlank()) {
            auctionRoom.setRoomPassword(generateRoomPassword());
        }
        auctionRoom.setStatus(resolveAuctionRoomStatus(auctionRoom.getStartTime(), auctionRoom.getEndTime()));
    }

    private void applyCurrentAuctionRoomStatus(AuctionRoom auctionRoom) {
        if (auctionRoom.getStatus() == AuctionRoomStatus.CANCELLED) {
            return;
        }
        auctionRoom.setStatus(resolveAuctionRoomStatus(auctionRoom.getStartTime(), auctionRoom.getEndTime()));
    }

    private AuctionRoomRequest sanitizeAuctionRoomRequest(AuctionRoomRequest request) {
        if (request == null || request.getProductId() == null) {
            throw new AppException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        BigDecimal minimumBid = request.getMinimumBid();
        BigDecimal depositAmount = request.getDepositAmount();
        Instant startTime = request.getStartTime();
        Instant endTime = request.getEndTime();

        if (minimumBid == null || minimumBid.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.AUCTION_MINIMUM_BID_REQUIRED);
        }

        if (depositAmount == null || depositAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.AUCTION_DEPOSIT_INVALID);
        }

        if (startTime == null || endTime == null || !endTime.isAfter(startTime)) {
            throw new AppException(ErrorCode.AUCTION_SCHEDULE_INVALID);
        }

        return AuctionRoomRequest.builder()
                .productId(request.getProductId())
                .minimumBid(minimumBid)
                .depositAmount(depositAmount)
                .startTime(startTime)
                .endTime(endTime)
                .build();
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

    private ProductStatus resolveProductStatus(AuctionRoomStatus roomStatus) {
        if (roomStatus == AuctionRoomStatus.CANCELLED) {
            return ProductStatus.CANCELLED;
        }
        if (roomStatus == AuctionRoomStatus.LIVE) {
            return ProductStatus.ACTIVE;
        }
        if (roomStatus == AuctionRoomStatus.CLOSED) {
            return ProductStatus.CANCELLED;
        }
        return ProductStatus.SCHEDULED;
    }

    private ProductResponse toProductResponse(Product product, AuctionRoom auctionRoom) {
        ProductResponse response = productMapper.toProductResponse(product);
        response.setAuctionRoom(auctionRoomMapper.toAuctionRoomResponse(auctionRoom));
        return response;
    }

    private void resetPreviousProductStatus(UUID previousProductId, UUID currentProductId) {
        if (previousProductId == null || previousProductId.equals(currentProductId)) {
            return;
        }
        productRepository.findById(previousProductId).ifPresent(previousProduct -> {
            previousProduct.setStatus(ProductStatus.DRAFT);
            productRepository.save(previousProduct);
        });
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

    private String generateNumericRoomCode() {
        Random random = new Random();
        String roomCode;
        do {
            roomCode = String.valueOf(100000 + random.nextInt(900000));
        } while (auctionRoomRepository.existsByRoomCode(roomCode));
        return roomCode;
    }
}
