package com.application.auction.mapper;

import com.application.auction.dto.request.AuctionRoomRequest;
import com.application.auction.dto.response.AuctionRoomAccessResponse;
import com.application.auction.dto.response.AuctionRoomResponse;
import com.application.auction.entity.AuctionRoom;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface AuctionRoomMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "roomCode", ignore = true)
    @Mapping(target = "roomPassword", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    AuctionRoom toAuctionRoom(AuctionRoomRequest request);

    @Mapping(target = "roomPassword", ignore = true)
    AuctionRoomResponse toAuctionRoomResponse(AuctionRoom auctionRoom);

    @Mapping(target = "roomId", expression = "java(auctionRoom.getId().toString())")
    AuctionRoomAccessResponse toAuctionRoomAccessResponse(AuctionRoom auctionRoom);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "roomCode", ignore = true)
    @Mapping(target = "roomPassword", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateAuctionRoom(@MappingTarget AuctionRoom auctionRoom, AuctionRoomRequest request);
}
