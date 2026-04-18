import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../data/auth_service.dart';
import '../../data/models/token_response.dart';
import '../../domain/auth_repository.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_label_widget.dart';
import '../widgets/auth_text_field_widget.dart';
import '../widgets/encrypted_footer_widget.dart';
import '../widgets/face_id_widget.dart';
import '../widgets/login_button_widget.dart';
import '../widgets/register_prompt_widget.dart';
import '../pages/register_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
        password: passwordController.text.trim(),
      );

      final TokenResponse? authData = response.data;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty ? response.message : 'Dang nhap thanh cong',
          ),
        ),
      );

      if (authData == null || !authData.authenticated) {
        throw Exception('Dang nhap that bai');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            accessToken: authData.accessToken,
            refreshToken: authData.refreshToken,
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

  void onForgotPressed() {}

  void onRegisterPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  void onFaceIdPressed() {}

  void onTogglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const AuthHeaderWidget(),
                    const SizedBox(height: 56),

                    const AuthLabelWidget(text: 'EMAIL ADDRESS'),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: emailController,
                      hintText: 'collector@prestigevault.com',
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 28),
                    const AuthLabelWidget(text: 'PASSWORD'),
                    const SizedBox(height: 12),
                    AuthTextFieldWidget(
                      controller: passwordController,
                      hintText: '••••••••••',
                      validator: Validators.validatePassword,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: onTogglePasswordVisibility,
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.hint,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onForgotPressed,
                        child: const Text(
                          'FORGOT CREDENTIALS?',
                          style: AppTextStyles.forgotText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    LoginButtonWidget(
                      isLoading: isLoading,
                      onPressed: onLoginPressed,
                    ),

                    const SizedBox(height: 34),
                    RegisterPromptWidget(
                      onRegister: onRegisterPressed,
                    ),

                    const SizedBox(height: 70),
                    FaceIdWidget(
                      onTap: onFaceIdPressed,
                    ),

                    const EncryptedFooterWidget(),
                    const SizedBox(height: 24),
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

