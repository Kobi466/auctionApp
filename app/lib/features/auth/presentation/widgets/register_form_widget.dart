import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'register_field_label.dart';
import 'register_terms_widget.dart';
import 'register_text_field_widget.dart';

class RegisterFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool acceptedTerms;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<bool?> onTermsChanged;

  const RegisterFormWidget({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.acceptedTerms,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RegisterFieldLabel(text: 'Họ và tên'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: fullNameController,
            hintText: 'Nhập họ và tên',
            validator: Validators.validateFullName,
            prefixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.lightSubText,
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Email'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: emailController,
            hintText: 'example@gmail.com',
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.lightSubText,
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Mật khẩu'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: passwordController,
            hintText: 'Nhập mật khẩu',
            validator: Validators.validatePassword,
            obscureText: obscurePassword,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.lightSubText,
            ),
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Xác nhận mật khẩu'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: confirmPasswordController,
            hintText: 'Nhập lại mật khẩu',
            validator: (value) {
              return Validators.validateConfirmPassword(
                value,
                passwordController.text,
              );
            },
            obscureText: obscureConfirmPassword,
            prefixIcon: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.lightSubText,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          const SizedBox(height: 20),

          RegisterTermsWidget(
            value: acceptedTerms,
            onChanged: onTermsChanged,
          ),
        ],
      ),
    );
  }
}