import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AuctionDetailStats extends StatelessWidget {
  final int bidCount;
  final String viewCount;
  final int participantCount;

  const AuctionDetailStats({
    super.key,
    required this.bidCount,
    required this.viewCount,
    required this.participantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatItem(Icons.gavel_rounded, bidCount.toString(), 'LƯỢT ĐẶT')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(Icons.visibility_outlined, viewCount, 'LƯỢT XEM')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(Icons.people_outline_rounded, participantCount.toString(), 'NGƯỜI THAM GIA')),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
