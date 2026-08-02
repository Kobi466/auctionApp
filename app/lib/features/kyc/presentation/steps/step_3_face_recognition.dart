import 'package:app/core/localization/app_translator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/kyc_controller.dart';
import '../pages/face_capture_page.dart';
import '../widgets/document_scan_card.dart';

class Step3FaceRecognition extends StatelessWidget {
  const Step3FaceRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KycController>();
    final faceImage = controller.kycData.faceImage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          AppText(
            'Xác thực khuôn mặt',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            'Vui lòng thực hiện chụp ảnh chân dung của bạn để đảm bảo tính bảo mật và xác minh danh tính chính chủ.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          DocumentScanCard(
            title: 'Ảnh chân dung',
            hintText: faceImage != null
                ? 'Đã chụp ảnh chân dung'
                : 'Nhấn để chụp chân dung',
            infoText:
                'Cần nhìn thẳng vào camera, không đeo kính râm hoặc khẩu trang. Đảm bảo khuôn mặt rõ nét.',
            hasImage: faceImage != null,
            imagePath: faceImage?.path,
            onTap: () async {
              final File? capturedFile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FaceCapturePage(),
                ),
              );

              if (capturedFile != null) {
                controller.updateData(
                  controller.kycData.copyWith(faceImage: capturedFile),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildTipsSection(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          AppText(
            'Mẹo chụp ảnh đẹp',
            style: AppTextStyles.registerTitleLight.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Ánh sáng đầy đủ',
            subtitle: 'Tránh chụp ngược sáng hoặc trong môi trường quá tối.',
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            icon: Icons.face_retouching_off_outlined,
            title: 'Không che mặt',
            subtitle:
                'Vui lòng tháo kính râm, khẩu trang hoặc mũ trước khi chụp.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, style: AppTextStyles.registerLabelLight),
              AppText(
                subtitle,
                style: AppTextStyles.registerSubtitleLight.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
