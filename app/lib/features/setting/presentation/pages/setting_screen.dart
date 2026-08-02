import 'package:app/core/localization/app_translator.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/profile_response.dart';
import '../../data/profile_service.dart';
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
  final ProfileService _profileService = ProfileService();

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
    final localeController = context.read<LocaleController>();
    final themeController = context.read<ThemeController>();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Không tìm thấy access token');
    }

    final setting = await _settingRepository.getProfile(
      accessToken: accessToken,
    );
    _setting = setting;

    if (mounted) {
      final preferences = _decodePreferences(setting.preferences);
      final language = preferences['language']?.toString().toLowerCase();
      final theme = preferences['theme']?.toString().toUpperCase();

      if (language == 'vi' || language == 'en') {
        await localeController.setLocale(language!);
      }
      if (theme == 'LIGHT' || theme == 'DARK') {
        await themeController.setDarkMode(theme == 'DARK');
      }
    }

    return setting;
  }

  Future<void> _changeDarkMode(bool enabled) async {
    await context.read<ThemeController>().setDarkMode(enabled);
    await _syncPreferences(theme: enabled ? 'DARK' : 'LIGHT');
  }

  Future<void> _changeLanguage(String languageCode) async {
    await context.read<LocaleController>().setLocale(languageCode);
    if (mounted) Navigator.of(context).pop();
    await _syncPreferences(language: languageCode);
  }

  Future<void> _syncPreferences({String? language, String? theme}) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      final updated = await _profileService.updatePreferences(
        accessToken: accessToken,
        language: language,
        theme: theme,
      );
      if (mounted) _setting = updated;
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText(l10n.preferenceSyncFailed)));
    }
  }

  void _showLanguagePicker() {
    final selectedLanguage = context
        .read<LocaleController>()
        .locale
        .languageCode;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: AppText(l10n.vietnamese),
                trailing: selectedLanguage == 'vi'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => _changeLanguage('vi'),
              ),
              ListTile(
                title: AppText(l10n.english),
                trailing: selectedLanguage == 'en'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => _changeLanguage('en'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final authRepository = AuthRepository(AuthService(ApiClient()));
    final refreshToken = AuthSession.instance.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      AuthSession.instance.clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    try {
      await authRepository.logout(token: refreshToken);
      AuthSession.instance.clear();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText('Dang xuat thanh cong')));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(e.toString().replaceFirst('Exception: ', '')),
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
      MaterialPageRoute(builder: (_) => EditSettingScreen(setting: setting)),
    );

    if (!mounted || updatedSetting == null) return;

    setState(() {
      _setting = updatedSetting;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AppText('Cap nhat setting thanh cong')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: const Icon(Icons.arrow_back),
        title: AppText(l10n.settings),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.help_outline, color: colorScheme.primary),
          ),
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
                child: AppText(
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
                  isVerified: setting.kycStatus.toUpperCase() == 'VERIFIED',
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
                  isVerified: setting.kycStatus.toUpperCase() == 'VERIFIED',
                ),
                SettingTileWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet Status',
                  trailingText: setting.isWalletActive ? 'Ready' : 'Inactive',
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
                SectionTitleWidget(title: l10n.preferences),
                SettingTileWidget(
                  icon: Icons.attach_money,
                  title: 'Primary Currency',
                  trailingText: currency,
                ),
                SettingTileWidget(
                  icon: Icons.language,
                  title: l10n.language,
                  trailingText: localeController.locale.languageCode == 'vi'
                      ? l10n.vietnamese
                      : l10n.english,
                  onTap: _showLanguagePicker,
                ),
                SwitchTileWidget(
                  icon: themeController.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: l10n.darkMode,
                  subtitle: themeController.isDarkMode
                      ? l10n.darkEnabled
                      : l10n.lightEnabled,
                  value: themeController.isDarkMode,
                  onChanged: _changeDarkMode,
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
