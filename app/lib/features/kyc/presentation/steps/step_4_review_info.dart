import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/kyc_controller.dart';

class Step4ReviewInfo extends StatelessWidget {
  const Step4ReviewInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KycController>();
    final data = controller.kycData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kiem tra thong tin',
            style: AppTextStyles.registerTitleLight.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui long kiem tra ky thong tin truoc khi gui yeu cau KYC.',
            style: AppTextStyles.registerSubtitleLight,
          ),
          if (controller.status != null && controller.status!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildStatusBox(controller),
          ],
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'Thong tin ca nhan',
            icon: Icons.person_outline,
            children: [
              _buildReviewItem('HO VA TEN', data.fullName),
              _buildReviewItem('SO CCCD/CMND', data.idNumber),
              _buildReviewItem('NGAY SINH', data.dob),
              _buildReviewItem('GIOI TINH', data.gender),
              _buildReviewItem('QUOC TICH', data.nationality),
              _buildReviewItem('QUE QUAN', data.placeOfOrigin),
              _buildReviewItem('NOI THUONG TRU', data.residentialAddress),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'Giay to va anh chan dung',
            icon: Icons.badge_outlined,
            children: [
              _buildImagePreview('Mat truoc CCCD', data.idFrontImage),
              const SizedBox(height: 16),
              _buildImagePreview('Mat sau CCCD', data.idBackImage),
              const SizedBox(height: 16),
              _buildImagePreview('Anh chan dung', data.faceImage),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatusBox(KycController controller) {
    final status = controller.status ?? '';
    final isRejected = status.toUpperCase() == 'REJECTED';
    final isVerified = status.toUpperCase() == 'VERIFIED';
    final backgroundColor = isRejected
        ? const Color(0xFFFFE8E8)
        : isVerified
        ? const Color(0xFFEAF8EE)
        : const Color(0xFFE8F0FF);
    final textColor = isRejected
        ? Colors.redAccent
        : isVerified
        ? Colors.green
        : AppColors.primaryBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trang thai hien tai: $status',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (controller.rejectedReason != null &&
              controller.rejectedReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              controller.rejectedReason!,
              style: TextStyle(color: textColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.registerLabelLight.copyWith(fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.registerSubtitleLight.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (value != null && value.trim().isNotEmpty)
                ? value.trim()
                : 'Chua cap nhat',
            style: AppTextStyles.registerTitleLight.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, File? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.registerSubtitleLight.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            image: imageFile != null
                ? DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageFile == null
              ? const Icon(Icons.image, color: Colors.grey, size: 40)
              : null,
        ),
      ],
    );
  }
}
