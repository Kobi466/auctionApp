import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class BannerSlider extends StatelessWidget {
  final List<ProductModel> products;

  const BannerSlider({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final liveCount = products
        .where((product) => product.auctionRoom?.status.toUpperCase() == 'LIVE')
        .length;
    final scheduledCount = products
        .where(
          (product) => product.auctionRoom?.status.toUpperCase() == 'SCHEDULED',
        )
        .length;
    final featuredProduct = products.isNotEmpty ? products.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Du lieu tu backend',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            featuredProduct != null
                ? featuredProduct.name
                : 'San dau gia hom nay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            featuredProduct != null
                ? (featuredProduct.shortDescription?.trim().isNotEmpty ?? false)
                      ? featuredProduct.shortDescription!.trim()
                      : 'Thuong hieu ${featuredProduct.brand}'
                : 'Danh sach san pham se hien thi ngay khi backend co du lieu.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: 'Tong san pham',
                  value: products.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  label: 'Dang live',
                  value: liveCount.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  label: 'Sap mo',
                  value: scheduledCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
