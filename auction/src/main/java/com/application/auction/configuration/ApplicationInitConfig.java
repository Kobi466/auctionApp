package com.application.auction.configuration;

import com.application.auction.entity.User;
import com.application.auction.enums.Role;
import com.application.auction.repository.RoleRepository;
import com.application.auction.repository.UserRepository;
import com.application.auction.service.ProfileService;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.HashSet;
import java.util.Set;

@Configuration
@Slf4j
public class ApplicationInitConfig {
    @Autowired
    PasswordEncoder passwordEncoder;

    @Bean
    ApplicationRunner applicationRunner(
            UserRepository userRepository,
            RoleRepository roleRepository,
            ProfileService profileService
    ) {
        return args -> {
            com.application.auction.entity.Role adminRole = roleRepository.findByName(Role.ADMIN.name())
                    .orElseGet(() -> roleRepository.save(com.application.auction.entity.Role.builder()
                            .name(Role.ADMIN.name())
                            .description("Administrator")
                            .build()));

            roleRepository.findByName(Role.USER.name())
                    .orElseGet(() -> roleRepository.save(com.application.auction.entity.Role.builder()
                            .name(Role.USER.name())
                            .description("Default user")
                            .build()));

            User adminUser = userRepository.findByEmail("admin2@gmail.com")
                    .orElseGet(() -> {
                        User user = User.builder()
                                .username("admin2@gmail.com")
                                .password(passwordEncoder.encode("admin3456789"))
                                .email("admin2@gmail.com")
                                .roles(new HashSet<>(Set.of(adminRole)))
                                .build();

                        User savedUser = userRepository.save(user);
                        log.info("Admin user created");
                        return savedUser;
                    });
            adminUser.setRoles(new HashSet<>(Set.of(adminRole)));
            adminUser = userRepository.save(adminUser);
            log.info("Admin role assigned to admin user");

            profileService.ensureProfileExists(adminUser);
        };
    }
}
