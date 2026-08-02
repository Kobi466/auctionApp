import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/kyc_controller.dart';
import '../widgets/kyc_text_field.dart';

class Step1PersonalInfo extends StatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  late final TextEditingController _idNumberController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _placeOfOriginController;
  late final TextEditingController _residentialAddressController;

  @override
  void initState() {
    super.initState();
    _idNumberController = TextEditingController();
    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _nationalityController = TextEditingController();
    _placeOfOriginController = TextEditingController();
    _residentialAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _placeOfOriginController.dispose();
    _residentialAddressController.dispose();
    super.dispose();
  }

  void _syncFromController(KycController controller) {
    final data = controller.kycData;

    _setIfNeeded(_idNumberController, data.idNumber);
    _setIfNeeded(_fullNameController, data.fullName);
    _setIfNeeded(_dobController, data.dob);
    _setIfNeeded(_genderController, data.gender);
    _setIfNeeded(_nationalityController, data.nationality);
    _setIfNeeded(_placeOfOriginController, data.placeOfOrigin);
    _setIfNeeded(_residentialAddressController, data.residentialAddress);
  }

  void _setIfNeeded(TextEditingController controller, String? value) {
    final normalized = value ?? '';
    if (controller.text != normalized) {
      controller.text = normalized;
    }
  }

  void _updateData(KycController controller) {
    controller.updateData(
      controller.kycData.copyWith(
        idNumber: _idNumberController.text,
        fullName: _fullNameController.text,
        dob: _dobController.text,
        gender: _genderController.text,
        nationality: _nationalityController.text,
        placeOfOrigin: _placeOfOriginController.text,
        residentialAddress: _residentialAddressController.text,
      ),
    );
  }

  Future<void> _pickDate(KycController controller) async {
    final initialDate =
        DateTime.tryParse(_dobController.text) ?? DateTime(2000, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    _dobController.text =
        '${pickedDate.year.toString().padLeft(4, '0')}-'
        '${pickedDate.month.toString().padLeft(2, '0')}-'
        '${pickedDate.day.toString().padLeft(2, '0')}';
    _updateData(controller);
  }

  Future<void> _pickGender(KycController controller) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        const options = ['Nam', 'Nu', 'Khac'];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (option) => ListTile(
                    title: AppText(option),
                    onTap: () => Navigator.pop(context, option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    _genderController.text = selected;
    _updateData(controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KycController>();
    _syncFromController(controller);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoBox(),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Giay to dinh danh',
            children: [
              KycTextField(
                label: 'So CMND/CCCD',
                hintText: AppTranslator.translate(
                  context,
                  'Nhap so the cua ban',
                ),
                controller: _idNumberController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(controller),
              ),
              const SizedBox(height: 16),
              KycTextField(
                label: 'Ho va ten day du',
                hintText: AppTranslator.translate(
                  context,
                  'Vi du: NGUYEN VAN A',
                ),
                controller: _fullNameController,
                onChanged: (_) => _updateData(controller),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Chi tiet ca nhan',
            children: [
              KycTextField(
                label: 'Ngay sinh',
                hintText: AppTranslator.translate(context, 'yyyy-mm-dd'),
                controller: _dobController,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                readOnly: true,
                onTap: () => _pickDate(controller),
              ),
              const SizedBox(height: 16),
              KycTextField(
                label: 'Gioi tinh',
                hintText: AppTranslator.translate(context, 'Chon gioi tinh'),
                controller: _genderController,
                suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 24),
                readOnly: true,
                onTap: () => _pickGender(controller),
              ),
              const SizedBox(height: 16),
              KycTextField(
                label: 'Quoc tich',
                hintText: AppTranslator.translate(context, 'Viet Nam'),
                controller: _nationalityController,
                onChanged: (_) => _updateData(controller),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Dia chi va que quan',
            children: [
              KycTextField(
                label: 'Que quan',
                hintText: AppTranslator.translate(
                  context,
                  'Tinh/Thanh pho, Quan/Huyen',
                ),
                controller: _placeOfOriginController,
                onChanged: (_) => _updateData(controller),
              ),
              const SizedBox(height: 16),
              KycTextField(
                label: 'Noi thuong tru',
                hintText: AppTranslator.translate(
                  context,
                  'So nha, ten duong, phuong/xa...',
                ),
                controller: _residentialAddressController,
                onChanged: (_) => _updateData(controller),
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
            child: AppText(
              'Vui long cung cap thong tin chinh xac theo CMND/CCCD de qua trinh xac minh dien ra nhanh hon.',
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
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
              AppText(
                title,
                style: AppTextStyles.registerTitleLight.copyWith(fontSize: 18),
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
