package com.application.auction.configuration;

import com.application.auction.entity.User;
import com.application.auction.enums.Role;
import com.application.auction.repository.UserRepository;
import com.application.auction.service.ProfileService;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.HashSet;

@Configuration
@Slf4j
public class ApplicationInitConfig {

    @Autowired
    PasswordEncoder passwordEncoder;

    @Bean
    ApplicationRunner applicationRunner(UserRepository userRepository, ProfileService profileService) {
        return args -> {
            User adminUser = userRepository.findByEmail("admin@gmail.com")
                    .orElseGet(() -> {
                        var roles = new HashSet<String>();
                        roles.add(Role.ADMIN.name());
                        User user = User.builder()
                                .username("admin@gmail.com")
                                .password(passwordEncoder.encode("admin"))
                              //  .roles(roles)
                                .email("admin@gmail.com")
                                .build();

                        User savedUser = userRepository.save(user);
                        log.info("Admin user created");
                        return savedUser;
                    });

            profileService.ensureProfileExists(adminUser);
        };
    }
}
