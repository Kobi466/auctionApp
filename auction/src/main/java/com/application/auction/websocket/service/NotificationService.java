package com.application.auction.websocket.service;

import com.application.auction.dto.response.NotificationResponse;
import com.application.auction.entity.Notification;
import com.application.auction.entity.User;
import com.application.auction.enums.ErrorCode;
import com.application.auction.exception.AppException;
import com.application.auction.mapper.NotificationMapper;
import com.application.auction.repository.NotificationRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.websocket.dto.event.NotificationEvent;
import com.application.auction.websocket.enums.EventType;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Sends a private notification to a user when they have been outbid.
     *
     * @param username  The username of the user to notify.
     * @param auctionId The ID of the auction where they were outbid.
     */
    public void notifyOutbid(String username, UUID auctionId) {
        NotificationEvent notification = new NotificationEvent(
                EventType.OUTBID,
                "You have been outbid on auction #" + auctionId,
                auctionId
        );
        // Sends a message to a user-specific destination, e.g., /user/{username}/queue/notifications
        messagingTemplate.convertAndSendToUser(username, "/queue/notifications", notification);
    }

    /**
     * Sends a private error message to a user.
     *
     * @param username     The username of the user who caused the error.
     * @param errorMessage The error message to send.
     */
    public void sendErrorToUser(String username, String errorMessage) {
        NotificationEvent errorEvent = new NotificationEvent(EventType.ERROR, errorMessage, null);
        messagingTemplate.convertAndSendToUser(username, "/queue/notifications", errorEvent);
    }

    NotificationRepository notificationRepository;
    UserRepository userRepository;
    NotificationMapper notificationMapper;

    @Transactional(readOnly = true)
    public List<NotificationResponse> getMyNotifications() {
        User currentUser = getCurrentUser();
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId()).stream()
                .map(notificationMapper::toNotificationResponse)
                .toList();
    }

    @Transactional
    public NotificationResponse markAsRead(UUID notificationId) {
        User currentUser = getCurrentUser();
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new AppException(ErrorCode.NOTIFICATION_NOT_FOUND));

        if (!notification.getUserId().equals(currentUser.getId())) {
            throw new AppException(ErrorCode.NOTIFICATION_NOT_FOUND);
        }

        notification.setRead(true);
        return notificationMapper.toNotificationResponse(notificationRepository.save(notification));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }
}
