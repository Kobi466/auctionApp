import 'package:app/core/localization/app_translator.dart';
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
  final TextEditingController phoneController;
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
    required this.phoneController,
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
            hintText: AppTranslator.translate(context, 'Nhập họ và tên'),
            validator: Validators.validateFullName,
            prefixIcon: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Email'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: emailController,
            hintText: AppTranslator.translate(context, 'example@gmail.com'),
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Số điện thoại'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: phoneController,
            hintText: AppTranslator.translate(context, 'Nhập số điện thoại'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              return null;
            },
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Mật khẩu'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: passwordController,
            hintText: AppTranslator.translate(context, 'Nhập mật khẩu'),
            validator: Validators.validatePassword,
            obscureText: obscurePassword,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 18),

          const RegisterFieldLabel(text: 'Xác nhận mật khẩu'),
          const SizedBox(height: 10),
          RegisterTextFieldWidget(
            controller: confirmPasswordController,
            hintText: AppTranslator.translate(context, 'Nhập lại mật khẩu'),
            validator: (value) {
              return Validators.validateConfirmPassword(
                value,
                passwordController.text,
              );
            },
            obscureText: obscureConfirmPassword,
            prefixIcon: Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),

          RegisterTermsWidget(value: acceptedTerms, onChanged: onTermsChanged),
        ],
      ),
    );
  }
}
