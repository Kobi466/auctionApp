import 'package:flutter/material.dart';

class AddProductDetailsForm extends StatelessWidget {
  final TextEditingController? nameController;
  final TextEditingController? brandController;
  final TextEditingController? provenanceController;
  final TextEditingController? authenticityController;
  final TextEditingController? rarityRankController;

  const AddProductDetailsForm({
    super.key,
    this.nameController,
    this.brandController,
    this.provenanceController,
    this.authenticityController,
    this.rarityRankController,
  });

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
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Color(0xFF2563EB),
              ),
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
            controller: nameController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Thương hiệu',
            hint: 'Rolex',
            controller: brandController,
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
            controller: provenanceController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Xac thuc san pham',
            hint: 'VD: Da kiem dinh, co certificate, Brand verified',
            controller: authenticityController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Do hiem',
            hint: 'Nhap so tu 1 - 10',
            controller: rarityRankController,
            keyboardType: TextInputType.number,
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
    TextEditingController? controller,
    TextInputType? keyboardType,
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
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
