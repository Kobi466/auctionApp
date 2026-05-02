package com.application.auction.service;

import com.application.auction.dto.response.AdminDashboardSummaryResponse;
import com.application.auction.enums.KycStatus;
import com.application.auction.repository.AuctionRoomRepository;
import com.application.auction.repository.KycDetailRepository;
import com.application.auction.repository.ProductRepository;
import com.application.auction.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminService {

    UserRepository userRepository;
    ProductRepository productRepository;
    AuctionRoomRepository auctionRoomRepository;
    KycDetailRepository kycDetailRepository;

    @Transactional(readOnly = true)
    @PreAuthorize("hasRole('ADMIN')")
    public AdminDashboardSummaryResponse getDashboardSummary() {
        return AdminDashboardSummaryResponse.builder()
                .totalUsers(userRepository.count())
                .totalProducts(productRepository.count())
                .totalAuctionRooms(auctionRoomRepository.count())
                .totalPendingKyc(kycDetailRepository.countByStatus(KycStatus.PENDING))
                .totalVerifiedKyc(kycDetailRepository.countByStatus(KycStatus.VERIFIED))
                .totalRejectedKyc(kycDetailRepository.countByStatus(KycStatus.REJECTED))
                .build();
    }
}

//
