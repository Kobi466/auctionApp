import 'package:app/core/localization/app_translator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/document_scan_card.dart';
import '../bloc/kyc_controller.dart';

class Step2IdUpload extends StatefulWidget {
  const Step2IdUpload({super.key});

  @override
  State<Step2IdUpload> createState() => _Step2IdUploadState();
}

class _Step2IdUploadState extends State<Step2IdUpload> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, bool isFront) async {
    final controller = context.read<KycController>();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        if (isFront) {
          controller.updateData(
            controller.kycData.copyWith(idFrontImage: file),
          );
        } else {
          controller.updateData(controller.kycData.copyWith(idBackImage: file));
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycData = context.watch<KycController>().kycData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          AppText(
            'Tải lên tài liệu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            'Vui lòng cung cấp hình ảnh rõ nét của CMND hoặc CCCD bản gốc để xác minh danh tính của bạn.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          DocumentScanCard(
            title: 'Mặt trước CMND/CCCD',
            hintText: kycData.idFrontImage != null
                ? 'Đã chụp mặt trước'
                : 'Nhấn để chụp mặt trước',
            infoText:
                'Đảm bảo hình ảnh rõ nét, không bị nhòe, không bị lóa sáng và đủ 4 góc của thẻ.',
            hasImage: kycData.idFrontImage != null,
            imagePath: kycData.idFrontImage?.path,
            onTap: () => _pickImage(context, true),
          ),
          const SizedBox(height: 24),
          DocumentScanCard(
            title: 'Mặt sau CMND/CCCD',
            hintText: kycData.idBackImage != null
                ? 'Đã chụp mặt sau'
                : 'Nhấn để chụp mặt sau',
            infoText:
                'Hình ảnh cần nhìn rõ các thông tin và mã vạch phía sau tài liệu.',
            hasImage: kycData.idBackImage != null,
            imagePath: kycData.idBackImage?.path,
            onTap: () => _pickImage(context, false),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
