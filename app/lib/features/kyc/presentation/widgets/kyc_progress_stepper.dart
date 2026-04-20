import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KycProgressStepper extends StatelessWidget {
  final int currentStep;
  final String title;
  final double progress;

  const KycProgressStepper({
    super.key,
    required this.currentStep,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BƯỚC $currentStep TRÊN 4',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primaryBlue,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.registerTitleLight.copyWith(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.registerTitleLight.copyWith(
                fontSize: 24,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
