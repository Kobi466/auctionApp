import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EditProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: enabled
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
