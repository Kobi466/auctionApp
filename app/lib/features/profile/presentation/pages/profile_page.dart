import 'package:app/core/localization/app_translator.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../auction/data/auction_participation_service.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../kyc/presentation/bloc/kyc_controller.dart';
import '../../../kyc/presentation/pages/kyc_main_page.dart';
import '../../../kyc/presentation/widgets/kyc_status_dialog.dart';
import '../../../setting/data/models/profile_response.dart';
import '../../../setting/data/profile_service.dart';
import '../../data/models/withdrawal_request_model.dart';
import '../../data/withdrawal_service.dart';
import '../widgets/wallet_card.dart';
import 'edit_profile_page.dart';
import 'won_products_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isNotificationEnabled = true;
  late final KycController _kycController;
  final ProfileService _profileService = ProfileService();
  final AuctionParticipationService _auctionService =
      AuctionParticipationService();
  final WithdrawalService _withdrawalService = WithdrawalService();
  ProfileResponse? _profile;
  bool _isProfileLoading = true;
  bool _isWalletLoading = true;
  num _withdrawableBalance = 0;
  num _lockedDeposit = 0;
  List<WithdrawalRequestModel> _withdrawals = const [];

  @override
  void initState() {
    super.initState();
    _kycController = KycController();
    _kycController.initialize(); // Lấy trạng thái KYC khi vào trang
    _loadProfile();
    _loadWalletSummary();
  }

  @override
  void dispose() {
    _kycController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() => _isProfileLoading = false);
      return;
    }

    try {
      final profile = await _profileService.getProfile(
        accessToken: accessToken,
      );
      if (!mounted) return;
      await _applyServerPreferences(profile.preferences);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isProfileLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProfileLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applyServerPreferences(String rawPreferences) async {
    final localeController = context.read<LocaleController>();
    final themeController = context.read<ThemeController>();
    try {
      final decoded = jsonDecode(rawPreferences);
      if (decoded is! Map<String, dynamic>) return;

      final language = decoded['language']?.toString().toLowerCase();
      final theme = decoded['theme']?.toString().toUpperCase();
      if (language == 'vi' || language == 'en') {
        await localeController.setLocale(language!);
      }
      if (theme == 'LIGHT' || theme == 'DARK') {
        await themeController.setDarkMode(theme == 'DARK');
      }
    } on FormatException {
      // Keep the settings stored on this device for legacy invalid JSON.
    }
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
      final profile = await _profileService.updatePreferences(
        accessToken: accessToken,
        language: language,
        theme: theme,
      );
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(AppLocalizations.of(context)!.preferenceSyncFailed),
        ),
      );
    }
  }

  void _showLanguagePicker() {
    final selected = context.read<LocaleController>().locale.languageCode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: AppText(l10n.vietnamese),
                trailing: selected == 'vi' ? const Icon(Icons.check) : null,
                onTap: () => _changeLanguage('vi'),
              ),
              ListTile(
                title: AppText(l10n.english),
                trailing: selected == 'en' ? const Icon(Icons.check) : null,
                onTap: () => _changeLanguage('en'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadWalletSummary() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() => _isWalletLoading = false);
      return;
    }

    try {
      final deposits = await _auctionService.getMyDeposits(
        accessToken: accessToken,
      );
      final withdrawals = await _withdrawalService.getMyWithdrawals(
        accessToken: accessToken,
      );
      num withdrawable = 0;
      num locked = 0;
      for (final deposit in deposits) {
        switch (deposit.status) {
          case 'REFUNDED':
            withdrawable += deposit.requiredAmount;
            break;
          case 'APPROVED':
          case 'PENDING_APPROVAL':
            locked += deposit.requiredAmount;
            break;
        }
      }
      for (final withdrawal in withdrawals) {
        if (withdrawal.status == 'PENDING' ||
            withdrawal.status == 'COMPLETED') {
          withdrawable -= withdrawal.amount;
        }
      }
      if (withdrawable < 0) {
        withdrawable = 0;
      }
      if (!mounted) return;
      setState(() {
        _withdrawableBalance = withdrawable;
        _lockedDeposit = locked;
        _withdrawals = withdrawals;
        _isWalletLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isWalletLoading = false);
    }
  }

  Future<void> _logout() async {
    final refreshToken = AuthSession.instance.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      _navigateToLogin();
      return;
    }

    final authRepository = AuthRepository(AuthService(ApiClient()));

    try {
      await authRepository.logout(token: refreshToken);
      AuthSession.instance.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText(AppLocalizations.of(context)!.logoutSuccess)),
      );

      _navigateToLogin();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin() {
    AuthSession.instance.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleKycTap() {
    final status = _kycController.status?.toUpperCase();

    if (_isKycVerified) {
      showDialog(
        context: context,
        builder: (context) => const KycStatusDialog(
          title: 'Đã xác thực danh tính',
          message: 'Quy trình xác minh đã hoàn thành',
          isSuccess: true,
        ),
      );
    } else if (status == 'PENDING') {
      showDialog(
        context: context,
        builder: (context) => const KycStatusDialog(
          title: 'Đang chờ xác thực',
          message: 'Yêu cầu của bạn đang được xử lý',
          isSuccess: false,
        ),
      );
    } else {
      // Trường hợp chưa gửi (null) hoặc bị từ chối (REJECTED)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycMainPage()),
      ).then(
        (_) => _kycController.initialize(),
      ); // Reload lại status sau khi quay về
    }
  }

  Future<void> _handleWithdraw() async {
    if (_withdrawableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Chua co so du co the rut')),
      );
      return;
    }
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _WithdrawalFormSheet(
        maxAmount: _withdrawableBalance,
        onSubmit: _submitWithdrawal,
      ),
    );
    if (submitted == true) {
      await _loadWalletSummary();
    }
  }

  Future<void> _submitWithdrawal({
    required num amount,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String branchName,
    required String userNote,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Khong tim thay access token');
    }
    await _withdrawalService.createWithdrawal(
      accessToken: accessToken,
      body: {
        'amount': amount,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        if (branchName.isNotEmpty) 'branchName': branchName,
        if (userNote.isNotEmpty) 'userNote': userNote,
      },
    );
  }

  void _showWithdrawalHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _WithdrawalHistorySheet(withdrawals: _withdrawals),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          l10n.profileTitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
            onPressed: () async {
              final updatedProfile = await Navigator.push<ProfileResponse>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profile: _profile),
                ),
              );
              if (updatedProfile == null || !mounted) return;
              setState(() => _profile = updatedProfile);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _kycController,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildProfileHeader(),
                const SizedBox(height: 24),
                WalletCard(
                  withdrawableBalance: _withdrawableBalance,
                  lockedDeposit: _lockedDeposit,
                  isLoading: _isWalletLoading,
                  onWithdraw: _handleWithdraw,
                  onHistory: _showWithdrawalHistory,
                ),
                const SizedBox(height: 32),
                _buildSection(
                  title: l10n.auctionActivity,
                  children: [
                    _buildMenuItem(
                      Icons.local_offer_outlined,
                      l10n.mySellingItems,
                    ),
                    _buildMenuItem(Icons.gavel_outlined, l10n.auctionHistory),
                    _buildMenuItem(
                      Icons.emoji_events_outlined,
                      l10n.wonProducts,
                    ),
                    _buildMenuItem(
                      Icons.favorite_border_rounded,
                      l10n.favorites,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.securityIdentity,
                  trailing: _isKycVerified ? _buildVerifiedBadge() : null,
                  children: [
                    _buildMenuItem(
                      Icons.badge_outlined,
                      l10n.identityVerification,
                      subtitle: _getKycSubtitle(),
                      onTap: _handleKycTap,
                    ),
                    _buildMenuItem(
                      Icons.lock_outline_rounded,
                      l10n.changePassword,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.settingsSection,
                  children: [
                    _buildToggleItem(
                      Icons.notifications_none_rounded,
                      l10n.notifications,
                      _isNotificationEnabled,
                      (value) {
                        setState(() => _isNotificationEnabled = value);
                      },
                    ),
                    _buildMenuItem(
                      Icons.language_rounded,
                      l10n.language,
                      trailingText: localeController.locale.languageCode == 'vi'
                          ? l10n.vietnamese
                          : l10n.english,
                      onTap: _showLanguagePicker,
                    ),
                    _buildToggleItem(
                      Icons.dark_mode_outlined,
                      l10n.darkMode,
                      themeController.isDarkMode,
                      _changeDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 4),
    );
  }

  String? _getKycSubtitle() {
    final l10n = AppLocalizations.of(context)!;
    final status = _kycController.status?.toUpperCase();
    if (_isKycVerified) return l10n.verified;
    if (status == 'PENDING') return l10n.pendingApproval;
    if (status == 'REJECTED') return l10n.rejectedRetry;
    return l10n.notVerified;
  }

  bool get _isKycVerified => _kycController.status?.toUpperCase() == 'VERIFIED';

  Future<void> _openWonProducts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WonProductsPage()),
    );
    if (!mounted) return;
    await _loadWalletSummary();
  }

  Widget _buildProfileHeader() {
    final profile = _profile;
    final name = _profileName(profile);
    final email = profile?.email.trim() ?? '';
    final avatar = _profileAvatar(profile);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatar),
              ),
            ),
            if (_isKycVerified)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AppText(
          _isProfileLoading ? AppLocalizations.of(context)!.loading : name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        AppText(
          email.isEmpty ? AppLocalizations.of(context)!.emailNotUpdated : email,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  String _profileName(ProfileResponse? profile) {
    final fullName = profile?.fullName?.trim() ?? '';
    if (fullName.isNotEmpty) return fullName;
    final email = profile?.email.trim() ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return AppLocalizations.of(context)!.user;
  }

  String _profileAvatar(ProfileResponse? profile) {
    final avatar = profile?.avatar?.trim() ?? '';
    if (avatar.isNotEmpty && !avatar.startsWith('data:image/')) return avatar;
    return 'https://i.pravatar.cc/300?u=${profile?.userId ?? 'profile'}';
  }

  Widget _buildSection({
    required String title,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: AppText(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? AppText(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitle.contains('từ chối') ? Colors.red : Colors.grey,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            AppText(
              trailingText,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
      onTap:
          onTap ??
          (icon == Icons.emoji_events_outlined ? _openWonProducts : null),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: AppText(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, color: Colors.purple, size: 12),
          SizedBox(width: 4),
          AppText(
            'VERIFIED',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: AppText(
          AppLocalizations.of(context)!.logout,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _WithdrawalFormSheet extends StatefulWidget {
  final num maxAmount;
  final Future<void> Function({
    required num amount,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String branchName,
    required String userNote,
  })
  onSubmit;

  const _WithdrawalFormSheet({required this.maxAmount, required this.onSubmit});

  @override
  State<_WithdrawalFormSheet> createState() => _WithdrawalFormSheetState();
}

class _WithdrawalFormSheetState extends State<_WithdrawalFormSheet> {
  final _amountController = TextEditingController();
  final _bankController = TextEditingController();
  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  final _branchController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = formatMoneyInput(widget.maxAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _branchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = num.tryParse(
      _amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final bankName = _bankController.text.trim();
    final accountNumber = _accountController.text.trim();
    final accountHolderName = _holderController.text.trim();
    final branchName = _branchController.text.trim();
    final userNote = _noteController.text.trim();

    if (amount == null || amount <= 0 || amount > widget.maxAmount) {
      _showError('So tien rut khong hop le');
      return;
    }
    if (bankName.isEmpty ||
        accountNumber.isEmpty ||
        accountHolderName.isEmpty) {
      _showError('Nhap du thong tin ngan hang');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        amount: amount,
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolderName: accountHolderName,
        branchName: branchName,
        userNote: userNote,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Da gui yeu cau rut tien')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.withdraw,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            AppText(
              l10n.maximumAmount(formatVnd(widget.maxAmount)),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _Input(
              controller: _amountController,
              label: l10n.amount,
              keyboardType: TextInputType.number,
              isMoney: true,
            ),
            _Input(controller: _bankController, label: l10n.bank),
            _Input(controller: _accountController, label: l10n.accountNumber),
            _Input(controller: _holderController, label: l10n.accountHolder),
            _Input(controller: _branchController, label: l10n.branch),
            _Input(controller: _noteController, label: l10n.note, maxLines: 2),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        l10n.submitForApproval,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalHistorySheet extends StatelessWidget {
  final List<WithdrawalRequestModel> withdrawals;

  const _WithdrawalHistorySheet({required this.withdrawals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.withdrawHistory,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            if (withdrawals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: AppText(l10n.noWithdrawalRequests)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: withdrawals.length,
                  itemBuilder: (context, index) {
                    final withdrawal = withdrawals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  formatVnd(withdrawal.amount),
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              _StatusText(status: withdrawal.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppText(
                            '${withdrawal.bankName} - ${withdrawal.accountNumber}',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if ((withdrawal.adminNote ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            AppText(
                              'Admin: ${withdrawal.adminNote}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isMoney;

  const _Input({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.isMoney = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: isMoney
            ? const [ThousandsSeparatorInputFormatter()]
            : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final String status;

  const _StatusText({required this.status});

  @override
  Widget build(BuildContext context) {
    return AppText(
      _label(context, status),
      style: TextStyle(
        color: _color(status),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _label(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'COMPLETED':
        return l10n.transferred;
      case 'REJECTED':
        return l10n.rejected;
      default:
        return l10n.pending;
    }
  }

  Color _color(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }
}
