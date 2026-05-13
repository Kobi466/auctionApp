//package com.application.auction.entity;
//
//import com.application.auction.websocket.enums.AuctionStatus;
//import jakarta.persistence.*;
//import lombok.Getter;
//import lombok.NoArgsConstructor;
//import lombok.Setter;
//
//import java.math.BigDecimal;
//import java.time.Instant;
//import java.util.UUID;
//
//@Entity
//@Table(name = "auctions")
//@Getter
//@Setter
//@NoArgsConstructor
//public class Auction {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.AUTO)
//    private UUID id;
//
//    @Column(nullable = false)
//    private String itemName;
//
//    @Column(length = 1000)
//    private String description;
//
//    @Column(nullable = false)
//    private BigDecimal startPrice;
//
//    @Column(nullable = false)
//    private BigDecimal currentPrice;
//
//    @Column(nullable = false)
//    private Instant startTime;
//
//    @Column(nullable = false)
//    private Instant endTime;
//
//    @Enumerated(EnumType.STRING)
//    @Column(nullable = false)
//    private AuctionStatus status;
//
//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "highest_bidder_id")
//    private User highestBidder;
//
//    // Assuming you have a Product entity to link to
//    // @OneToOne
//    // @JoinColumn(name = "product_id")
//    // private Product product;
//}
