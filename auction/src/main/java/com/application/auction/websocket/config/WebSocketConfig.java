package com.application.auction.websocket.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final WebSocketAuthChannelInterceptor authChannelInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // These are prefixes for messages sent from the server to the client (broadcasts).
        config.enableSimpleBroker("/topic", "/queue");
        // This is the prefix for messages sent from the client to the server (@MessageMapping).
        config.setApplicationDestinationPrefixes("/app");
        // This is the prefix for user-specific destinations (private messages).
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // The endpoint that clients will connect to.
        // `setAllowedOriginPatterns("*")` allows connections from any origin (useful for development).
        // `withSockJS()` provides a fallback for browsers that don't support WebSocket.
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        // Register our custom JWT authentication interceptor.
        registration.interceptors(authChannelInterceptor);
    }
}
