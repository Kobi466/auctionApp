package com.application.auction.mapper;

import com.application.auction.dto.request.AuctionPaymentConfigRequest;
import com.application.auction.dto.response.AuctionPaymentConfigResponse;
import com.application.auction.entity.AuctionPaymentConfig;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface AuctionPaymentConfigMapper {
    AuctionPaymentConfig toAuctionPaymentConfig(AuctionPaymentConfigRequest request);

    AuctionPaymentConfigResponse toAuctionPaymentConfigResponse(AuctionPaymentConfig auctionPaymentConfig);

    void updateAuctionPaymentConfig(@MappingTarget AuctionPaymentConfig auctionPaymentConfig, AuctionPaymentConfigRequest request);
}
