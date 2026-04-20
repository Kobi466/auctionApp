import 'package:flutter/material.dart';
import 'live_auction_card.dart';

class LiveAuctionSection extends StatelessWidget {
  const LiveAuctionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Đấu giá trực tiếp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cơ hội sở hữu ngay lúc này',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Text(
                'Tất cả',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const LiveAuctionCard(
                  imageUrl: 'https://i.imgur.com/apple_watch.png',
                  title: 'Apple Watch Ultra 2 - Mới 100%',
                  currentPrice: '12.500.000 đ',
                  timeLeft: '04:22:11',
                );
              }
              return const LiveAuctionCard(
                imageUrl: 'https://i.imgur.com/sony_headphones.png',
                title: 'Sony WH-1000XM5 Silver Edition',
                currentPrice: '6.800.000 đ',
                timeLeft: '01:15:30',
              );
            },
          ),
        ),
      ],
    );
  }
}
