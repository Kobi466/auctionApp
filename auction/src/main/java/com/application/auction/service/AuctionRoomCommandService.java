package com.application.auction.service;

import com.application.auction.dto.request.AuctionRoomRequest;
import com.application.auction.dto.response.ProductResponse;
import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Product;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.enums.ProductStatus;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.AuctionRoomMapper;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.websocket.enums.AuctionRoomStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Locale;
import java.util.Random;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuctionRoomCommandService {

    AuctionRoomRepository auctionRoomRepository;
    ProductRepository productRepository;
    UserRepository userRepository;
    AuctionRoomMapper auctionRoomMapper;
    AuctionRoomSummaryService summaryService;

    public ProductResponse createAuctionRoom(AuctionRoomRequest request) {
        AuctionRoomRequest sanitized = sanitize(request);
        Product product = getProduct(sanitized.getProductId());
        if (auctionRoomRepository.findByProductId(product.getId()).isPresent()) {
            throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_EXISTS);
        }

        AuctionRoom room = auctionRoomMapper.toAuctionRoom(sanitized);
        applyProductFields(room, product, sanitized.getMinimumBid());
        room.setSeller(getCurrentUser());
        applyBusinessFields(room);
        AuctionRoom savedRoom = auctionRoomRepository.save(room);
        product.setStatus(resolveProductStatus(savedRoom.getStatus()));
        return summaryService.toProductResponse(productRepository.save(product), savedRoom);
    }

    public ProductResponse updateAuctionRoom(UUID roomId, AuctionRoomRequest request) {
        AuctionRoom room = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        AuctionRoomRequest sanitized = sanitize(request);
        Product product = getProduct(sanitized.getProductId());
        ensureProductAvailableForRoom(product.getId(), roomId);

        UUID previousProductId = room.getProduct().getId();
        auctionRoomMapper.updateAuctionRoom(room, sanitized);
        applyProductFields(room, product, sanitized.getMinimumBid());
        applyBusinessFields(room);
        AuctionRoom savedRoom = auctionRoomRepository.save(room);
        resetPreviousProductStatus(previousProductId, product.getId());
        product.setStatus(resolveProductStatus(savedRoom.getStatus()));
        return summaryService.toProductResponse(productRepository.save(product), savedRoom);
    }

    public ProductResponse cancelAuctionRoom(UUID roomId) {
        AuctionRoom room = auctionRoomRepository.findById(roomId)
                .orElseThrow(() -> new AppException(ErrorCode.AUCTION_ROOM_NOT_FOUND));
        if (room.getStatus() == AuctionRoomStatus.CLOSED || room.getStatus() == AuctionRoomStatus.CANCELLED) {
            throw new AppException(ErrorCode.AUCTION_SCHEDULE_INVALID);
        }

        room.setStatus(AuctionRoomStatus.CANCELLED);
        AuctionRoom savedRoom = auctionRoomRepository.save(room);
        Product product = getProduct(savedRoom.getProduct().getId());
        product.setStatus(ProductStatus.CANCELLED);
        return summaryService.toProductResponse(productRepository.save(product), savedRoom);
    }

    private AuctionRoomRequest sanitize(AuctionRoomRequest request) {
        if (request == null || request.getProductId() == null) {
            throw new AppException(ErrorCode.PRODUCT_NOT_FOUND);
        }
        BigDecimal minimumBid = request.getMinimumBid();
        Instant startTime = request.getStartTime();
        Instant endTime = request.getEndTime();
        if (minimumBid == null || minimumBid.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException(ErrorCode.AUCTION_MINIMUM_BID_REQUIRED);
        }
        if (startTime == null || endTime == null || !endTime.isAfter(startTime)) {
            throw new AppException(ErrorCode.AUCTION_SCHEDULE_INVALID);
        }
        return AuctionRoomRequest.builder()
                .productId(request.getProductId())
                .minimumBid(minimumBid)
                .depositAmount(minimumBid)
                .startTime(startTime)
                .endTime(endTime)
                .build();
    }

    private void applyProductFields(AuctionRoom room, Product product, BigDecimal minimumBid) {
        room.setProduct(product);
        room.setMinBidIncrement(minimumBid);
        room.setStartingPrice(product.getStartingPrice());
        room.setDepositAmount(product.getStartingPrice());
    }

    private void applyBusinessFields(AuctionRoom room) {
        if (room.getRoomCode() == null || room.getRoomCode().isBlank() || room.getRoomCode().startsWith("ROOM-")) {
            room.setRoomCode(generateNumericRoomCode());
        }
        if (room.getRoomPassword() == null || room.getRoomPassword().isBlank()) {
            room.setRoomPassword(generateRoomPassword());
        }
        room.setStatus(resolveStatus(room.getStartTime(), room.getEndTime()));
        room.setTimeExtended(false);
        room.setWinnerNotified(false);
    }

    private void ensureProductAvailableForRoom(UUID productId, UUID roomId) {
        auctionRoomRepository.findByProductId(productId)
                .filter(existingRoom -> !existingRoom.getId().equals(roomId))
                .ifPresent(existingRoom -> {
                    throw new AppException(ErrorCode.AUCTION_ROOM_ALREADY_EXISTS);
                });
    }

    private ProductStatus resolveProductStatus(AuctionRoomStatus roomStatus) {
        if (roomStatus == AuctionRoomStatus.CANCELLED) return ProductStatus.CANCELLED;
        if (roomStatus == AuctionRoomStatus.LIVE) return ProductStatus.ACTIVE;
        if (roomStatus == AuctionRoomStatus.CLOSED) return ProductStatus.CANCELLED;
        if (roomStatus == AuctionRoomStatus.SOLD) return ProductStatus.SOLD;
        if (roomStatus == AuctionRoomStatus.FAILED) return ProductStatus.AUCTION_FAILED;
        return ProductStatus.SCHEDULED;
    }

    private AuctionRoomStatus resolveStatus(Instant startTime, Instant endTime) {
        Instant now = Instant.now();
        if (now.isBefore(startTime)) return AuctionRoomStatus.SCHEDULED;
        if (now.isAfter(endTime)) return AuctionRoomStatus.CLOSED;
        return AuctionRoomStatus.LIVE;
    }

    private void resetPreviousProductStatus(UUID previousProductId, UUID currentProductId) {
        if (previousProductId == null || previousProductId.equals(currentProductId)) return;
        productRepository.findById(previousProductId).ifPresent(previousProduct -> {
            previousProduct.setStatus(ProductStatus.DRAFT);
            productRepository.save(previousProduct);
        });
    }

    private String generateRoomPassword() {
        String characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random random = new Random();
        StringBuilder builder = new StringBuilder(8);
        for (int index = 0; index < 8; index++) builder.append(characters.charAt(random.nextInt(characters.length())));
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

    private Product getProduct(UUID productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
}
