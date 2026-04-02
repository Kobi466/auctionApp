import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FaceIdWidget extends StatelessWidget {
  final VoidCallback onTap;

  const FaceIdWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gold,
                child: Icon(
                  Icons.face_retouching_natural,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'SIGN IN WITH FACEID',
          style: AppTextStyles.faceIdText,
        ),
      ],
    );
  }
}