import 'package:app/core/localization/app_translator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DocumentScanCard extends StatelessWidget {
  final String title;
  final String hintText;
  final String infoText;
  final VoidCallback onTap;
  final bool hasImage;
  final String? imagePath;

  const DocumentScanCard({
    super.key,
    required this.title,
    required this.hintText,
    required this.infoText,
    required this.onTap,
    this.hasImage = false,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: AppTextStyles.registerTitleLight.copyWith(fontSize: 18),
              ),
              const Icon(Icons.credit_card, color: AppColors.primaryBlue),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasImage
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlue.withOpacity(0.1),
                  width: hasImage ? 2 : 1,
                ),
                image: hasImage && imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.1,
                          child: const Icon(
                            Icons.person,
                            size: 150,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppText(
                              hintText,
                              style: AppTextStyles.registerSubtitleLight
                                  .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.primaryBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    infoText,
                    style: AppTextStyles.registerSubtitleLight.copyWith(
                      fontSize: 11,
                      color: AppColors.primaryBlue.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
