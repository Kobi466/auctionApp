import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AuctionDetailInfo extends StatelessWidget {
  final String category;
  final String productId;
  final String title;
  final String currentPrice;
  final String timeRemaining;

  const AuctionDetailInfo({
    super.key,
    required this.category,
    required this.productId,
    required this.title,
    required this.currentPrice,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'ID: $productId',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildInfoBox(
                label: 'GIÁ HIỆN TẠI',
                value: currentPrice,
                valueColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoBox(
                label: 'THỜI GIAN CÒN LẠI',
                value: timeRemaining,
                valueColor: const Color(0xFFD11F66),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: valueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: valueColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
