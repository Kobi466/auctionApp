package com.application.auction.mapper;

import com.application.auction.dto.response.BidResponse;
import com.application.auction.entity.Bid;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface BidMapper {
    @Mapping(target = "userName", ignore = true)
    @Mapping(target = "userAvatar", ignore = true)
    @Mapping(target = "leading", ignore = true)
    BidResponse toBidResponse(Bid bid);
}
