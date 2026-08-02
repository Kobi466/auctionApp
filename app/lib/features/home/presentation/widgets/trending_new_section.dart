import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class TrendingNewSection extends StatelessWidget {
  final List<ProductModel> products;

  const TrendingNewSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final trendingCount = products
        .where(
          (product) =>
              product.tags.any((tag) => tag.toLowerCase().contains('trend')),
        )
        .length;

    final sortedProducts = products.toList()
      ..sort((first, second) {
        final firstTime =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondTime =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return secondTime.compareTo(firstTime);
      });

    final latestProduct = sortedProducts.isEmpty ? null : sortedProducts.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              context: context,
              title: 'Sản phẩm xu hướng',
              subtitle: trendingCount > 0
                  ? '$trendingCount Sản phẩm đang được quan tâm'
                  : 'Danh sach duoc dong bo tu backend',
              buttonText: 'Xem thêm',
              icon: Icons.trending_up_rounded,
              bgColor: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF4F7DFF),
              btnColor: const Color(0xFFD3DFFF),
              textColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(
              context: context,
              title: 'Vừa mới đăng',
              subtitle: latestProduct != null
                  ? latestProduct.name
                  : 'Chưa có sản phẩm mới',
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
    required BuildContext context,
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
          AppText(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          AppText(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
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
            child: AppText(
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
