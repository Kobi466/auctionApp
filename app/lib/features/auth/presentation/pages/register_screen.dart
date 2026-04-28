import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_service.dart';
import '../../domain/auth_repository.dart';
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
  late final AuthRepository authRepository;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(AuthService(ApiClient()));
  }

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
          content: Text('Vui long dong y voi dieu khoan su dung'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty ? response.message : 'Dang ky thanh cong',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            initialEmail: emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void onGoToLoginPressed() {
    Navigator.pushReplacement(
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
