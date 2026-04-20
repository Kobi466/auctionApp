import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/kyc_text_field.dart';

class Step1PersonalInfo extends StatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoBox(),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Giấy tờ định danh',
            children: [
              const KycTextField(
                label: 'Số CMND/CCCD',
                hintText: 'Nhập số thẻ của bạn',
              ),
              const SizedBox(height: 16),
              const KycTextField(
                label: 'Họ và tên đầy đủ',
                hintText: 'VÍ DỤ: NGUYỄN VĂN A',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Chi tiết cá nhân',
            children: [
              KycTextField(
                label: 'Ngày sinh',
                hintText: 'mm/dd/yyyy',
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                readOnly: true,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              KycTextField(
                label: 'Giới tính',
                hintText: 'Chọn giới tính',
                suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 24),
                readOnly: true,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              const KycTextField(
                label: 'Quốc tịch',
                hintText: 'Việt Nam',
                readOnly: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Địa chỉ & Quê quán',
            children: [
              const KycTextField(
                label: 'Quê quán',
                hintText: 'Tỉnh/Thành phố, Quận/Huyện',
              ),
              const SizedBox(height: 16),
              const KycTextField(
                label: 'Nơi thường trú',
                hintText: 'Số nhà, tên đường, phường/xã...',
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vui lòng cung cấp thông tin chính xác theo CMND/CCCD của bạn để đảm bảo quá trình xác minh diễn ra nhanh chóng.',
              style: AppTextStyles.registerSubtitleLight.copyWith(
                fontSize: 13,
                color: AppColors.primaryBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
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
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.registerTitleLight.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
