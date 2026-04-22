package com.application.auction.mapper;

import com.application.auction.dto.response.AuctionDepositResponse;
import com.application.auction.entity.AuctionDeposit;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AuctionDepositMapper {
    AuctionDepositResponse toAuctionDepositResponse(AuctionDeposit auctionDeposit);
}
