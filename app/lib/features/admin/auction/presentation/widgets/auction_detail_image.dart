import 'package:flutter/material.dart';

import '../../../../../core/utils/image_provider_helper.dart';

class AuctionDetailImage extends StatelessWidget {
  final String imageUrl;
  final bool isLive;

  const AuctionDetailImage({
    super.key,
    required this.imageUrl,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xFFE2E8F0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image(
            image: appImageProvider(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF94A3B8),
                  size: 48,
                ),
              );
            },
          ),
        ),
        if (isLive)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD11F66).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
