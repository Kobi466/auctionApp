package com.application.auction.configuration;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class DatabaseSchemaMigrationConfig {

    JdbcTemplate jdbcTemplate;

    @Bean
    ApplicationRunner auctionDepositStatusMigration() {
        return args -> jdbcTemplate.execute("""
                ALTER TABLE auction_deposits
                MODIFY status VARCHAR(30) NOT NULL
                """);
    }
}
