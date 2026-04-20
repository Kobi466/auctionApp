import 'package:flutter/material.dart';

class TrendingNewSection extends StatelessWidget {
  const TrendingNewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              title: 'Sản phẩm Xu hướng',
              subtitle: 'Nhu cầu đấu giá cao nhất tuần này',
              buttonText: 'Xem thêm',
              icon: Icons.trending_up_rounded,
              bgColor: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF4F7DFF),
              btnColor: const Color(0xFFD3DFFF),
              textColor: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(
              title: 'Vừa mới đăng',
              subtitle: 'Cập nhật 2 phút trước',
              buttonText: 'Xem mới nhất',
              icon: Icons.verified_rounded,
              bgColor: const Color(0xFF262D55),
              iconColor: const Color(0xFF4F7DFF),
              btnColor: Colors.white.withOpacity(0.15),
              textColor: Colors.white,
              isDark: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color btnColor,
    required Color textColor,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
