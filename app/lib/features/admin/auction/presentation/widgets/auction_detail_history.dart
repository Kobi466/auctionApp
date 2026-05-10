import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AuctionDetailHistory extends StatelessWidget {
  const AuctionDetailHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lịch sử đặt giá',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildHistoryItem(
          name: 'Trần Minh Quân',
          time: '3 PHÚT TRƯỚC',
          price: '450.000.000 VNĐ',
          isHighest: true,
          avatarUrl: 'https://i.pravatar.cc/150?u=1',
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          name: 'Lê Thủy Chi',
          time: '8 PHÚT TRƯỚC',
          price: '445.000.000 VNĐ',
          avatarUrl: 'https://i.pravatar.cc/150?u=2',
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          name: 'Nguyễn Hoàng Nam',
          time: '15 PHÚT TRƯỚC',
          price: '440.000.000 VNĐ',
          avatarUrl: 'https://i.pravatar.cc/150?u=3',
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String name,
    required String time,
    required String price,
    bool isHighest = false,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighest ? AppColors.primaryBlue.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighest ? AppColors.primaryBlue.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isHighest ? AppColors.primaryBlue : const Color(0xFF1E293B),
                ),
              ),
              if (isHighest)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CAO NHẤT',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
