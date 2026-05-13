//package com.application.auction.service;
//
//import com.application.auction.dto.response.NotificationResponse;
//import com.application.auction.entity.Notification;
//import com.application.auction.entity.User;
//import com.application.auction.enums.ErrorCode;
//import com.application.auction.exception.AppException;
//import com.application.auction.mapper.NotificationMapper;
//import com.application.auction.repository.NotificationRepository;
//import com.application.auction.repository.UserRepository;
//import lombok.AccessLevel;
//import lombok.RequiredArgsConstructor;
//import lombok.experimental.FieldDefaults;
//import org.springframework.security.core.context.SecurityContextHolder;
//import org.springframework.stereotype.Service;
//import org.springframework.transaction.annotation.Transactional;
//
//import java.util.List;
//import java.util.UUID;
//
//@Service
//@RequiredArgsConstructor
//@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
//public class NotificationService {
//
//    NotificationRepository notificationRepository;
//    UserRepository userRepository;
//    NotificationMapper notificationMapper;
//
//    @Transactional(readOnly = true)
//    public List<NotificationResponse> getMyNotifications() {
//        User currentUser = getCurrentUser();
//        return notificationRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId()).stream()
//                .map(notificationMapper::toNotificationResponse)
//                .toList();
//    }
//
//    @Transactional
//    public NotificationResponse markAsRead(UUID notificationId) {
//        User currentUser = getCurrentUser();
//        Notification notification = notificationRepository.findById(notificationId)
//                .orElseThrow(() -> new AppException(ErrorCode.NOTIFICATION_NOT_FOUND));
//
//        if (!notification.getUserId().equals(currentUser.getId())) {
//            throw new AppException(ErrorCode.NOTIFICATION_NOT_FOUND);
//        }
//
//        notification.setRead(true);
//        return notificationMapper.toNotificationResponse(notificationRepository.save(notification));
//    }
//
//    private User getCurrentUser() {
//        String email = SecurityContextHolder.getContext().getAuthentication().getName();
//        return userRepository.findByEmail(email)
//                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
//    }
//
//}