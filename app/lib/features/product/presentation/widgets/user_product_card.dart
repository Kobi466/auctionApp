import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_provider_helper.dart';

class UserProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String time;
  final String price;
  final int participants;
  final bool isLive;
  final VoidCallback? onAction;
  final VoidCallback? onDetails;

  const UserProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.time,
    required this.price,
    required this.participants,
    this.isLive = true,
    this.onAction,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: appImageProvider(imageUrl),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.pink.withOpacity(0.9)
                        : Colors.indigo.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    isLive ? 'LIVE' : 'SẮP ĐẤU GIÁ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: isLive ? const Color(0xFF2563EB) : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(
                        isLive ? time : 'Bắt đầu sau: $time',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLive
                              ? const Color(0xFF2563EB)
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      '$participants',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.favorite_border_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: onDetails,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AppText(
                          'Chi tiết',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AppText(
                          'Đấu giá',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
