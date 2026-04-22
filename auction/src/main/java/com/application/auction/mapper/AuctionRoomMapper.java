package com.application.auction.mapper;

import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.entity.AuctionRoom;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AuctionRoomMapper {
    @Mapping(target = "roomPassword", ignore = true)
    AuctionRoomResponse toAuctionRoomResponse(AuctionRoom auctionRoom);

    @Mapping(target = "roomId", expression = "java(auctionRoom.getId().toString())")
    AuctionRoomAccessResponse toAuctionRoomAccessResponse(AuctionRoom auctionRoom);
}
