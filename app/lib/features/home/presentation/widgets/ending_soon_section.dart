import 'package:flutter/material.dart';
import 'ending_soon_card.dart';

class EndingSoonSection extends StatelessWidget {
  const EndingSoonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Sắp kết thúc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chỉ còn vài phút cuối',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const EndingSoonCard(
                  imageUrl: 'https://i.imgur.com/nike_shoes.png',
                  title: 'Nike Air Jordan 1 Retro',
                  price: '4.200.000 đ',
                  timeLeft: '2 PHÚT',
                );
              }
              return const EndingSoonCard(
                imageUrl: 'https://i.imgur.com/iphone_15.png',
                title: 'iPhone 15 Pro Max 256GB',
                price: '21.900.000 đ',
                timeLeft: '5 PHÚT',
              );
            },
          ),
        ),
      ],
    );
  }
}
