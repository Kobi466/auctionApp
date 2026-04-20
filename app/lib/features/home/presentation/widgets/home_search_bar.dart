import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF94A3B8),
            ),
            hintText: 'Tìm kiếm vật phẩm, thương hiệu...',
            hintStyle: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
