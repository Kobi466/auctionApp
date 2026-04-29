import 'package:flutter/material.dart';
import 'admin_product_card.dart';

class AdminProductList extends StatelessWidget {
  const AdminProductList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu dựa trên hình ảnh
    final products = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
        'title': 'Vintage Rolex GMT Master II',
        'sku': 'LX-9921',
        'status': 'hoạt động',
        'category': 'Đồng hồ',
        'brand': 'Rolex',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
        'title': 'Porsche 911 Carrera S',
        'sku': 'CR-4402',
        'status': 'bản nháp',
        'category': 'Xe cộ',
        'brand': 'Porsche',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
        'title': 'Louis Vuitton Keepall 50',
        'sku': 'BG-0012',
        'status': 'hoạt động',
        'category': 'Thời trang',
        'brand': 'LV',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8',
        'title': 'Vũ điệu Ánh sáng',
        'sku': 'AR-7729',
        'status': 'đã kết thúc',
        'category': 'Nghệ thuật',
        'brand': 'Modern',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return AdminProductCard(
          imageUrl: product['imageUrl']!,
          title: product['title']!,
          sku: product['sku']!,
          status: product['status']!,
          category: product['category']!,
          brand: product['brand']!,
          onEdit: () {},
          onView: () {},
          onDelete: () {},
        );
      },
    );
  }
}
