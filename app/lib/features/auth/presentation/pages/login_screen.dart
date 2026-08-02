import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../data/auth_session.dart';
import '../../data/auth_service.dart';
import '../../data/models/token_response.dart';
import '../../domain/auth_repository.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_label_widget.dart';
import '../widgets/auth_text_field_widget.dart';
import '../widgets/login_button_widget.dart';
import '../widgets/register_prompt_widget.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String initialEmail;

  const LoginScreen({super.key, this.initialEmail = ''});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AuthRepository authRepository;

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(AuthService(ApiClient()));
    emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLoginPressed() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final TokenResponse? authData = response.data;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            response.message.isNotEmpty
                ? response.message
                : 'Dang nhap thanh cong',
          ),
        ),
      );

      if (authData == null || !authData.authenticated) {
        throw Exception('Dang nhap that bai');
      }

      AuthSession.instance.save(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
        roles: authData.roles,
        isAdmin: authData.isAdmin,
      );

      final isAdmin = AuthSession.instance.isAdmin;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isAdmin ? const AdminDashboardPage() : const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(e.toString().replaceFirst('Exception: ', '')),
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

  void onForgotPressed() {}

  void onRegisterPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void onTogglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const AuthHeaderWidget(),
                    const SizedBox(height: 48),
                    const AuthLabelWidget(text: 'EMAIL ADDRESS'),
                    const SizedBox(height: 8),
                    AuthTextFieldWidget(
                      controller: emailController,
                      hintText: AppTranslator.translate(
                        context,
                        'example@gmail.com',
                      ),
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const AuthLabelWidget(text: 'PASSWORD'),
                    const SizedBox(height: 8),
                    AuthTextFieldWidget(
                      controller: passwordController,
                      hintText: AppTranslator.translate(
                        context,
                        'Nhap mat khau',
                      ),
                      validator: Validators.validatePassword,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: onTogglePasswordVisibility,
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onForgotPressed,
                        child: AppText(
                          'Quen mat khau?',
                          style: AppTextStyles.registerLinkLight.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LoginButtonWidget(
                      isLoading: isLoading,
                      onPressed: onLoginPressed,
                    ),
                    const SizedBox(height: 32),
                    RegisterPromptWidget(onRegister: onRegisterPressed),
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
