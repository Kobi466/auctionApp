import 'package:flutter/material.dart';

class AddProductDetailsForm extends StatelessWidget {
  const AddProductDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'THÔNG TIN CHI TIẾT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Tên sản phẩm',
            hint: 'VD: Đồng hồ Rolex Submariner 2023',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Thương hiệu',
            hint: 'Rolex',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Giá khởi điểm',
            hint: 'VND 0.000.000',
            prefixText: 'VNĐ ',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Nguồn gốc (Provenance)',
            hint: 'Lịch sử sở hữu, quốc gia xuất xứ...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
