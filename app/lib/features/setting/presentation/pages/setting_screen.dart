import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_controller.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/profile_response.dart';
import '../../domain/profile_repository_impl.dart';
import 'edit_setting_screen.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/setting_header_widget.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/setting_tile_widget.dart';
import '../widgets/switch_tile_widget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late final ProfileRepositoryImpl _settingRepository;

  Future<ProfileResponse>? _settingFuture;
  ProfileResponse? _setting;

  @override
  void initState() {
    super.initState();
    _settingRepository = ProfileRepositoryImpl();
    _settingFuture = _loadSetting();
  }

  Future<ProfileResponse> _loadSetting() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Không tìm thấy access token');
    }

    final setting = await _settingRepository.getProfile(
      accessToken: accessToken,
    );
    _setting = setting;
    return setting;
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final authRepository = AuthRepository(AuthService(ApiClient()));
    final refreshToken = AuthSession.instance.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      AuthSession.instance.clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
      return;
    }

    try {
      await authRepository.logout(token: refreshToken);
      AuthSession.instance.clear();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dang xuat thanh cong'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _decodePreferences(String raw) {
    if (raw.trim().isEmpty) return const {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      return const {};
    }

    return const {};
  }

  String _displayName(ProfileResponse setting) {
    if (setting.fullName != null && setting.fullName!.trim().isNotEmpty) {
      return setting.fullName!.trim();
    }
    return setting.email;
  }

  String _kycLabel(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return 'Fully Verified';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  Future<void> _openEditSetting(ProfileResponse setting) async {
    final updatedSetting = await Navigator.of(context).push<ProfileResponse>(
      MaterialPageRoute(
        builder: (_) => EditSettingScreen(setting: setting),
      ),
    );

    if (!mounted || updatedSetting == null) return;

    setState(() {
      _setting = updatedSetting;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cap nhat setting thanh cong')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: const Icon(Icons.arrow_back),
        title: const Text('Elite Account Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.help_outline, color: colorScheme.primary),
          )
        ],
      ),
      body: FutureBuilder<ProfileResponse>(
        future: _settingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final setting = _setting ?? snapshot.data!;
          final preferences = _decodePreferences(setting.preferences);
          final currency = preferences['currency']?.toString() ?? 'USD';
          final language = preferences['language']?.toString() ?? 'English';
          final twoFactor = preferences['twoFactorEnabled'] == true;
          final biometric = preferences['biometricEnabled'] == true;
          final pushNotification = preferences['pushNotification'] == true;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ProfileHeaderWidget(
                  fullName: _displayName(setting),
                  email: setting.email,
                  avatar: setting.avatar,
                  bio: setting.bio,
                  isVerified:
                  setting.kycStatus.toUpperCase() == 'VERIFIED',
                ),
                const SizedBox(height: 20),
                ActionButtonWidget(
                  text: 'EDIT SETTING',
                  color: colorScheme.primary,
                  onPressed: () => _openEditSetting(setting),
                ),
                const SizedBox(height: 14),
                const SectionTitleWidget(title: 'IDENTITY STATUS'),
                SettingTileWidget(
                  icon: Icons.verified,
                  title: 'KYC Verification',
                  subtitle: _kycLabel(setting.kycStatus),
                  isVerified:
                  setting.kycStatus.toUpperCase() == 'VERIFIED',
                ),
                SettingTileWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet Status',
                  trailingText:
                  setting.isWalletActive ? 'Ready' : 'Inactive',
                ),
                const SectionTitleWidget(title: 'ACCOUNT SECURITY'),
                SettingTileWidget(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: setting.email,
                ),
                SettingTileWidget(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: setting.phoneNumber ?? 'Not updated',
                ),
                SwitchTileWidget(
                  icon: Icons.security,
                  title: '2-Factor Authentication',
                  subtitle: 'Preference sync pending',
                  value: twoFactor,
                ),
                SwitchTileWidget(
                  icon: Icons.face,
                  title: 'Biometric Login',
                  subtitle: 'Preference sync pending',
                  value: biometric,
                ),
                const SectionTitleWidget(title: 'PREFERENCES'),
                SettingTileWidget(
                  icon: Icons.attach_money,
                  title: 'Primary Currency',
                  trailingText: currency,
                ),
                SettingTileWidget(
                  icon: Icons.language,
                  title: 'Language',
                  trailingText: language,
                ),
                SwitchTileWidget(
                  icon: themeController.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: themeController.isDarkMode
                      ? 'Dark interface enabled'
                      : 'Light interface enabled',
                  value: themeController.isDarkMode,
                  onChanged: themeController.setDarkMode,
                ),
                SwitchTileWidget(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  value: pushNotification,
                ),
                const SizedBox(height: 30),
                ActionButtonWidget(
                  text: 'EXPORT PERSONAL DATA',
                  color: colorScheme.primary,
                ),
                ActionButtonWidget(
                  text: 'LOG OUT',
                  color: Colors.red,
                  isOutlined: true,
                  onPressed: () => _onLogoutPressed(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
