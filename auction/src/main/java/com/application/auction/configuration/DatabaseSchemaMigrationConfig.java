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
        return args -> {
            createAuctionDepositsIfMissing();
            relaxLegacyColumnIfPresent("auction_deposits", "status", "VARCHAR(30) NOT NULL");
            relaxLegacyColumnIfPresent("products", "status", "VARCHAR(30) NOT NULL");
            migrateAuctionRooms();
            migrateBids();
        };
    }

    private void createAuctionDepositsIfMissing() {
        if (!tableExists("auction_deposits")) {
            jdbcTemplate.execute("""
                    CREATE TABLE auction_deposits (
                        id CHAR(36) NOT NULL,
                        auction_room_id CHAR(36) NOT NULL,
                        product_id CHAR(36) NOT NULL,
                        user_id CHAR(36) NOT NULL,
                        required_amount DECIMAL(19, 2) NOT NULL,
                        transfer_content VARCHAR(120) NOT NULL,
                        status VARCHAR(30) NOT NULL,
                        admin_note VARCHAR(255) NULL,
                        user_note VARCHAR(255) NULL,
                        payment_submitted_at TIMESTAMP(6) NULL,
                        approved_at TIMESTAMP(6) NULL,
                        created_at TIMESTAMP(6) NOT NULL,
                        updated_at TIMESTAMP(6) NULL,
                        PRIMARY KEY (id),
                        UNIQUE KEY uk_auction_deposits_transfer_content (transfer_content)
                    )
                    """);
        }
    }

    private void migrateAuctionRooms() {
        relaxLegacyColumnIfPresent("auction_rooms", "status", "VARCHAR(30) NOT NULL");
        addColumnIfMissing("auction_rooms", "current_price", "DECIMAL(19, 2) NOT NULL DEFAULT 0.00");
        addColumnIfMissing("auction_rooms", "min_bid_increment", "DECIMAL(19, 2) NOT NULL DEFAULT 1.00");
        addColumnIfMissing("auction_rooms", "starting_price", "DECIMAL(19, 2) NOT NULL DEFAULT 0.00");
        addColumnIfMissing("auction_rooms", "participant_count", "INT DEFAULT 0");
        addColumnIfMissing("auction_rooms", "highest_bidder_id", "CHAR(36) NULL");
        addColumnIfMissing("auction_rooms", "seller_id", "CHAR(36) NULL");
        addColumnIfMissing("auction_rooms", "is_private", "BOOLEAN NOT NULL DEFAULT FALSE");
        addColumnIfMissing("auction_rooms", "room_code", "VARCHAR(60) NULL");
        addColumnIfMissing("auction_rooms", "room_password", "VARCHAR(255) NULL");
        addColumnIfMissing("auction_rooms", "time_extended", "BOOLEAN NOT NULL DEFAULT FALSE");
        addColumnIfMissing("auction_rooms", "winner_notified", "BOOLEAN NOT NULL DEFAULT FALSE");
        addColumnIfMissing("auction_rooms", "current_winner_rank", "INT NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_status", "VARCHAR(30) NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_method", "VARCHAR(30) NULL");
        addColumnIfMissing("auction_rooms", "winner_shipping_address", "VARCHAR(1000) NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_receipt_url", "VARCHAR(500) NULL");
        relaxLegacyColumnIfPresent("auction_rooms", "winner_payment_receipt_url", "LONGTEXT NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_user_note", "VARCHAR(1000) NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_admin_note", "VARCHAR(1000) NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_rejected_count", "INT NOT NULL DEFAULT 0");
        addColumnIfMissing("auction_rooms", "winner_payment_submitted_at", "TIMESTAMP(6) NULL");
        addColumnIfMissing("auction_rooms", "winner_payment_confirmed_at", "TIMESTAMP(6) NULL");
        relaxLegacyColumnIfPresent("auction_rooms", "minimum_bid", "DECIMAL(19, 2) NULL DEFAULT 0.00");

        if (tableExists("auction_rooms") && columnExists("auction_rooms", "starting_price")) {
            jdbcTemplate.execute("""
                    UPDATE auction_rooms
                    SET current_price = starting_price
                    WHERE current_price = 0 OR current_price IS NULL
                    """);
        }

        if (tableExists("auction_rooms") && tableExists("products")) {
            jdbcTemplate.execute("""
                    UPDATE auction_rooms ar
                    JOIN products p ON p.id = ar.product_id
                    SET ar.seller_id = p.created_by_admin_id
                    WHERE ar.seller_id IS NULL
                    """);
        }
    }

    private void migrateBids() {
        relaxLegacyColumnIfPresent("bids", "id", "CHAR(36) NOT NULL");
        addColumnIfMissing("bids", "auction_room_id", "CHAR(36) NULL");
        addColumnIfMissing("bids", "bidder_id", "CHAR(36) NULL");
        addColumnIfMissing("bids", "timestamp", "TIMESTAMP(6) NULL");
        addColumnIfMissing("bids", "created_at", "DATETIME(6) NULL");
        addColumnIfMissing("bids", "amount", "DECIMAL(19, 2) NOT NULL DEFAULT 0.00");
        relaxLegacyColumnIfPresent("bids", "user_id", "CHAR(36) NULL");

        if (columnExists("bids", "auctionRoom_id")) {
            jdbcTemplate.execute("""
                    UPDATE bids
                    SET auction_room_id = auctionRoom_id
                    WHERE auction_room_id IS NULL
                    """);
        }

        if (columnExists("bids", "user_id")) {
            jdbcTemplate.execute("""
                    UPDATE bids
                    SET bidder_id = user_id
                    WHERE bidder_id IS NULL
                      AND user_id IS NOT NULL
                    """);
        }

        if (tableExists("bids")) {
            jdbcTemplate.execute("""
                    UPDATE bids
                    SET created_at = COALESCE(created_at, CURRENT_TIMESTAMP(6)),
                        timestamp = COALESCE(timestamp, CURRENT_TIMESTAMP(6))
                    WHERE created_at IS NULL OR timestamp IS NULL
                    """);
        }
    }

    private void addColumnIfMissing(String tableName, String columnName, String columnDefinition) {
        if (tableExists(tableName) && !columnExists(tableName, columnName)) {
            jdbcTemplate.execute("ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnDefinition);
        }
    }

    private void relaxLegacyColumnIfPresent(String tableName, String columnName, String columnDefinition) {
        if (columnExists(tableName, columnName)) {
            jdbcTemplate.execute("ALTER TABLE " + tableName + " MODIFY " + columnName + " " + columnDefinition);
        }
    }

    private boolean columnExists(String tableName, String columnName) {
        Integer count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = DATABASE()
                  AND table_name = ?
                  AND column_name = ?
                """, Integer.class, tableName, columnName);
        return count != null && count > 0;
    }

    private boolean tableExists(String tableName) {
        Integer count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = DATABASE()
                  AND table_name = ?
                """, Integer.class, tableName);
        return count != null && count > 0;
    }
}
