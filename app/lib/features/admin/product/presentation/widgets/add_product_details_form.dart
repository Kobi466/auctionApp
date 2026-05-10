import 'package:flutter/material.dart';
import '../../../../../core/utils/currency_formatter.dart';

class AddProductDetailsForm extends StatelessWidget {
  final TextEditingController? nameController;
  final TextEditingController? brandController;
  final TextEditingController? startingPriceController;
  final TextEditingController? provenanceController;
  final TextEditingController? authenticityController;
  final TextEditingController? rarityRankController;
  final DateTime? plannedStartTime;
  final VoidCallback? onPickPlannedStartTime;
  final VoidCallback? onClearPlannedStartTime;

  const AddProductDetailsForm({
    super.key,
    this.nameController,
    this.brandController,
    this.startingPriceController,
    this.provenanceController,
    this.authenticityController,
    this.rarityRankController,
    this.plannedStartTime,
    this.onPickPlannedStartTime,
    this.onClearPlannedStartTime,
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
              Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'THONG TIN CHI TIET',
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
            label: 'Ten san pham',
            hint: 'VD: Dong ho Rolex Submariner 2023',
            controller: nameController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Thuong hieu',
            hint: 'Rolex',
            controller: brandController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Gia khoi diem',
            hint: '150,000,000',
            prefixText: 'VNĐ ',
            controller: startingPriceController,
            keyboardType: TextInputType.number,
            isMoney: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Nguon goc (Provenance)',
            hint: 'Lich su so huu, quoc gia xuat xu...',
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
          const SizedBox(height: 20),
          _buildPlannedStartTimeField(),
        ],
      ),
    );
  }

  Widget _buildPlannedStartTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngay gio bat dau du kien',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPickPlannedStartTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined, color: Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plannedStartTime == null
                        ? 'Chua co ngay bat dau'
                        : _formatDateTime(plannedStartTime!),
                    style: TextStyle(
                      color: plannedStartTime == null
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (plannedStartTime != null)
                  IconButton(
                    onPressed: onClearPlannedStartTime,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: const Color(0xFF64748B),
                    tooltip: 'Xoa ngay bat dau',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? prefixText,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool isMoney = false,
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
            inputFormatters: isMoney
                ? const [ThousandsSeparatorInputFormatter()]
                : null,
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
