import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm, mã SKU...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}
