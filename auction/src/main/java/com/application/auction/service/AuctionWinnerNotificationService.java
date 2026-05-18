package com.application.auction.service;

import com.application.auction.entity.AuctionRoom;
import com.application.auction.entity.Bid;
import com.application.auction.entity.Notification;
import com.application.auction.entity.Product;
import com.application.auction.entity.Profile;
import com.application.auction.entity.User;
import com.application.auction.repository.BidRepository;
import com.application.auction.repository.NotificationRepository;
import com.application.auction.repository.ProfileRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Slf4j
public class AuctionWinnerNotificationService {

    final BidRepository bidRepository;
    final NotificationRepository notificationRepository;
    final ProfileRepository profileRepository;
    final ObjectProvider<JavaMailSender> mailSenderProvider;

    @Value("${spring.mail.username:}")
    String mailFrom;

    @Value("${spring.mail.host:}")
    String mailHost;

    public void notifyWinner(AuctionRoom room) {
        List<Bid> ranking = getUniqueBidderRanking(room.getId(), 5);
        if (ranking.isEmpty()) {
            return;
        }

        Bid winningBid = ranking.get(0);
        User winner = winningBid.getBidder();
        Product product = room.getProduct();
        BigDecimal paymentAmount = winningBid.getAmount();
        String title = "Ban da thang dau gia";
        String message = "Ban da thang dau gia san pham \"" + product.getName()
                + "\" voi so tien " + formatVnd(paymentAmount)
                + ". Vui long thanh toan de admin xet duyet va tien hanh gui do.";

        notificationRepository.save(Notification.builder()
                .userId(winner.getId())
                .title(title)
                .message(message)
                .type("AUCTION_WINNER_PAYMENT")
                .build());

        sendWinnerEmail(winner, product, paymentAmount, ranking);
    }

    public Notification sendOfferToCandidate(AuctionRoom room, Bid candidateBid, int rank, boolean sendEmail) {
        User candidate = candidateBid.getBidder();
        Product product = room.getProduct();
        String title = rank == 1 ? "Thong bao thanh toan dau gia" : "Den luot nhan san pham dau gia";
        String message = rank == 1
                ? "Ban dang la nguoi xep hang 1 cua san pham \"" + product.getName()
                + "\". Vui long thanh toan " + formatVnd(candidateBid.getAmount())
                + " de admin xet duyet va gui do."
                : "Nguoi xep hang truoc khong nhan san pham \"" + product.getName()
                + "\". Ban dang xep hang " + rank + " voi gia " + formatVnd(candidateBid.getAmount())
                + ". Vui long xac nhan neu muon nhan san pham.";

        Notification notification = notificationRepository.save(Notification.builder()
                .userId(candidate.getId())
                .title(title)
                .message(message)
                .type(rank == 1 ? "AUCTION_WINNER_PAYMENT" : "AUCTION_WINNER_OFFER")
                .build());

        if (sendEmail) {
            sendPlainEmail(candidate, title, message);
        }

        return notification;
    }

    public Notification notifyForfeited(AuctionRoom room, Bid bid, int rank, boolean sendEmail) {
        User user = bid.getBidder();
        String title = "Mat coc dau gia";
        String message = "Ban da khong nhan san pham \"" + room.getProduct().getName()
                + "\" o hang " + rank + ". Tien coc cua ban se bi mat theo quy dinh phong dau gia.";

        Notification notification = notificationRepository.save(Notification.builder()
                .userId(user.getId())
                .title(title)
                .message(message)
                .type("AUCTION_DEPOSIT_FORFEITED")
                .build());

        if (sendEmail) {
            sendPlainEmail(user, title, message);
        }

        return notification;
    }

    private List<Bid> getUniqueBidderRanking(UUID roomId, int limit) {
        Map<UUID, Bid> bestBidByUser = new LinkedHashMap<>();
        bidRepository.findByAuctionRoomIdOrderByAmountDescCreatedAtAsc(roomId)
                .forEach(bid -> bestBidByUser.putIfAbsent(bid.getBidder().getId(), bid));
        return bestBidByUser.values().stream()
                .limit(limit)
                .toList();
    }

    private void sendWinnerEmail(User winner, Product product, BigDecimal paymentAmount, List<Bid> ranking) {
        String subject = "Thong bao thang dau gia - " + product.getName();
        String body = buildEmailBody(winner, product, paymentAmount, ranking);
        sendPlainEmail(winner, subject, body);
    }

    private void sendPlainEmail(User user, String subject, String body) {
        JavaMailSender mailSender = mailSenderProvider.getIfAvailable();
        if (mailHost == null || mailHost.isBlank()
                || mailSender == null
                || user.getEmail() == null
                || user.getEmail().isBlank()) {
            log.warn("Email not sent because SMTP is not configured or user email is empty.");
            return;
        }

        SimpleMailMessage mail = new SimpleMailMessage();
        if (mailFrom != null && !mailFrom.isBlank()) {
            mail.setFrom(mailFrom);
        }
        mail.setTo(user.getEmail());
        mail.setSubject(subject);
        mail.setText(body);
        try {
            mailSender.send(mail);
        } catch (Exception exception) {
            log.warn("Email could not be sent to {}", user.getEmail(), exception);
        }
    }

    private String buildEmailBody(User winner, Product product, BigDecimal paymentAmount, List<Bid> ranking) {
        String displayName = profileRepository.findById(winner.getId())
                .map(Profile::getFullName)
                .filter(name -> name != null && !name.isBlank())
                .orElse(winner.getUsername());

        StringBuilder body = new StringBuilder();
        body.append("Xin chao ").append(displayName).append(",\n\n")
                .append("Ban da thang dau gia san pham: ").append(product.getName()).append("\n")
                .append("So tien can thanh toan: ").append(formatVnd(paymentAmount)).append("\n\n")
                .append("Bang xep hang phong dau gia:\n");

        for (int index = 0; index < ranking.size(); index++) {
            Bid bid = ranking.get(index);
            body.append(index + 1)
                    .append(". ")
                    .append(resolveBidderName(bid.getBidder()))
                    .append(" - ")
                    .append(formatVnd(bid.getAmount()))
                    .append("\n");
        }

        body.append("\nVui long thanh toan theo huong dan trong ung dung. Sau khi thanh toan, don se duoc admin xet duyet va tien hanh gui do.");
        return body.toString();
    }

    private String resolveBidderName(User user) {
        return profileRepository.findById(user.getId())
                .map(Profile::getFullName)
                .filter(name -> name != null && !name.isBlank())
                .orElse(user.getUsername());
    }

    private String formatVnd(BigDecimal amount) {
        NumberFormat formatter = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN"));
        return formatter.format(amount);
    }
}
