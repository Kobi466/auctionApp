import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/profile_response.dart';
import '../../domain/profile_repository_impl.dart';
import 'edit_profile_screen.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/setting_tile_widget.dart';
import '../widgets/switch_tile_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String accessToken;
  final String refreshToken;

  const ProfileScreen({
    super.key,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepositoryImpl _profileRepository;

  Future<ProfileResponse>? _profileFuture;
  ProfileResponse? _profile;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl();
    _profileFuture = _loadProfile();
  }

  Future<ProfileResponse> _loadProfile() async {
    final profile = await _profileRepository.getProfile(
      accessToken: widget.accessToken,
    );
    _profile = profile;
    return profile;
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final authRepository = AuthRepository(AuthService(ApiClient()));

    try {
      await authRepository.logout(token: widget.refreshToken);

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
    if (raw.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      return const {};
    }

    return const {};
  }

  String _displayName(ProfileResponse profile) {
    if (profile.fullName != null && profile.fullName!.trim().isNotEmpty) {
      return profile.fullName!.trim();
    }
    return profile.email;
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

  Future<void> _openEditProfile(ProfileResponse profile) async {
    final updatedProfile = await Navigator.of(context).push<ProfileResponse>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          accessToken: widget.accessToken,
          profile: profile,
        ),
      ),
    );

    if (!mounted || updatedProfile == null) {
      return;
    }

    setState(() {
      _profile = updatedProfile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cap nhat profile thanh cong')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back),
        title: const Text('Elite Account Settings'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help_outline, color: Colors.amber),
          )
        ],
      ),
      body: FutureBuilder<ProfileResponse>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = _profile ?? snapshot.data!;
          final preferences = _decodePreferences(profile.preferences);
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
                  fullName: _displayName(profile),
                  email: profile.email,
                  avatar: profile.avatar,
                  bio: profile.bio,
                  isVerified: profile.kycStatus.toUpperCase() == 'VERIFIED',
                ),
                const SizedBox(height: 20),
                ActionButtonWidget(
                  text: 'EDIT PROFILE',
                  color: Colors.amber,
                  onPressed: () => _openEditProfile(profile),
                ),
                const SizedBox(height: 14),
                const SectionTitleWidget(title: 'IDENTITY STATUS'),
                SettingTileWidget(
                  icon: Icons.verified,
                  title: 'KYC Verification',
                  subtitle: _kycLabel(profile.kycStatus),
                  isVerified: profile.kycStatus.toUpperCase() == 'VERIFIED',
                ),
                SettingTileWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet Status',
                  trailingText: profile.isWalletActive ? 'Ready' : 'Inactive',
                ),
                const SectionTitleWidget(title: 'ACCOUNT SECURITY'),
                SettingTileWidget(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: profile.email,
                ),
                SettingTileWidget(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: profile.phoneNumber ?? 'Not updated',
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
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  value: pushNotification,
                ),
                const SizedBox(height: 30),
                const ActionButtonWidget(
                  text: 'EXPORT PERSONAL DATA',
                  color: Colors.amber,
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
