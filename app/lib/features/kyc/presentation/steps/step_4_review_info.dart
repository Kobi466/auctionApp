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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kiểm tra thông tin',
            style: AppTextStyles.registerTitleLight.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng kiểm tra kỹ các thông tin dưới đây trước khi gửi yêu cầu xác minh danh tính.',
            style: AppTextStyles.registerSubtitleLight,
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            context,
            title: 'Thông tin cá nhân',
            icon: Icons.person_outline,
            onEdit: () => controller.setStep(1),
            children: [
              _buildReviewItem('HỌ VÀ TÊN', data.fullName ?? 'NGUYỄN VĂN A'),
              _buildReviewItem('SỐ CCCD/CMND', data.idNumber ?? '012345678910'),
              _buildReviewItem('NGÀY SINH', data.dob ?? '20/10/1995'),
              _buildReviewItem('GIỚI TÍNH', data.gender ?? 'Nam'),
              _buildReviewItem('ĐỊA CHỈ THƯỜNG TRÚ', data.residentialAddress ?? 'Số 123, Đường Láng, Quận Đống Đa, TP. Hà Nội'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            context,
            title: 'Giấy tờ & Ảnh chân dung',
            icon: Icons.badge_outlined,
            onEdit: () => controller.setStep(2),
            children: [
              _buildImagePreview('Mặt trước CCCD', data.idFrontImage),
              const SizedBox(height: 16),
              _buildImagePreview('Mặt sau CCCD', data.idBackImage),
              const SizedBox(height: 16),
              _buildImagePreview('Ảnh chân dung', data.faceImage),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
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
              const Spacer(),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
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
            value,
            style: AppTextStyles.registerTitleLight.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, dynamic imageFile) {
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
