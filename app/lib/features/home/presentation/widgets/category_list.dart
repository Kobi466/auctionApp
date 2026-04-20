import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.laptop, 'label': 'Điện tử'},
      {'icon': Icons.directions_car, 'label': 'Xe cộ'},
      {'icon': Icons.checkroom, 'label': 'Thời trang'},
      {'icon': Icons.home_outlined, 'label': 'Nhà cửa'},
      {'icon': Icons.watch_outlined, 'label': 'Đồng hồ'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  categories[index]['icon'] as IconData,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                categories[index]['label'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
