package com.application.auction.mapper;

import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.entity.Notification;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NotificationMapper {
    NotificationResponse toNotificationResponse(Notification notification);
}
