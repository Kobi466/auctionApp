import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EditProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onCameraTap;

  const EditProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBlue, width: 2),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
        GestureDetector(
          onTap: onCameraTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
