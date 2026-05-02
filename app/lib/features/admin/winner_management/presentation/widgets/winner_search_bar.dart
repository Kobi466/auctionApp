import 'package:flutter/material.dart';

class WinnerSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const WinnerSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Tìm tên khách hàng, mã phiên...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}
