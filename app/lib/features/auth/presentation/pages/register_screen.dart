import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_screen.dart';
import '../widgets/auth_card_container_widget.dart';
import '../widgets/register_button_widget.dart';
import '../widgets/register_form_widget.dart';
import '../widgets/register_header_widget.dart';
import '../widgets/register_prompt_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  bool acceptedTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void onTogglePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void onToggleConfirmPassword() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  void onTermsChanged(bool? value) {
    setState(() {
      acceptedTerms = value ?? false;
    });
  }

  Future<void> onRegisterPressed() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void onGoToLoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AuthCardContainerWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RegisterHeaderWidget(),
                    const SizedBox(height: 32),
                    RegisterFormWidget(
                      formKey: formKey,
                      fullNameController: fullNameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      obscurePassword: obscurePassword,
                      obscureConfirmPassword: obscureConfirmPassword,
                      acceptedTerms: acceptedTerms,
                      onTogglePassword: onTogglePassword,
                      onToggleConfirmPassword: onToggleConfirmPassword,
                      onTermsChanged: onTermsChanged,
                    ),
                    const SizedBox(height: 28),
                    RegisterButtonWidget(
                      isLoading: isLoading,
                      onPressed: onRegisterPressed,
                    ),
                    const SizedBox(height: 22),
                    RegisterPromptWidget(
                      onRegister: onGoToLoginPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}