import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../kyc/presentation/bloc/kyc_controller.dart';
import '../../../kyc/presentation/pages/kyc_main_page.dart';
import '../../../kyc/presentation/widgets/kyc_status_dialog.dart';
import '../widgets/wallet_card.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;
  late final KycController _kycController;

  @override
  void initState() {
    super.initState();
    _kycController = KycController();
    _kycController.initialize(); // Lấy trạng thái KYC khi vào trang
  }

  @override
  void dispose() {
    _kycController.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Đăng xuất thành công')),
      );

      _navigateToLogin();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin() {
    AuthSession.instance.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _handleKycTap() {
    final status = _kycController.status?.toUpperCase();

    if (status == 'APPROVED') {
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
        MaterialPageRoute(
          builder: (context) => const KycMainPage(),
        ),
      ).then((_) => _kycController.initialize()); // Reload lại status sau khi quay về
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cá nhân',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
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
                const WalletCard(balance: 45200000),
                const SizedBox(height: 32),
                _buildSection(
                  title: 'HOẠT ĐỘNG ĐẤU GIÁ',
                  children: [
                    _buildMenuItem(Icons.local_offer_outlined, 'Đồ tôi đang bán'),
                    _buildMenuItem(Icons.gavel_outlined, 'Lịch sử đấu giá'),
                    _buildMenuItem(Icons.emoji_events_outlined, 'Sản phẩm đã thắng'),
                    _buildMenuItem(
                      Icons.favorite_border_rounded,
                      'Danh sách yêu thích',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'BẢO MẬT VÀ ĐỊNH DANH',
                  trailing: _kycController.status?.toUpperCase() == 'APPROVED' ? _buildVerifiedBadge() : null,
                  children: [
                    _buildMenuItem(
                      Icons.badge_outlined,
                      'Xác minh danh tính',
                      subtitle: _getKycSubtitle(),
                      onTap: _handleKycTap,
                    ),
                    _buildMenuItem(Icons.lock_outline_rounded, 'Đổi mật khẩu'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'CÀI ĐẶT',
                  children: [
                    _buildToggleItem(
                      Icons.notifications_none_rounded,
                      'Thông báo',
                      _isNotificationEnabled,
                      (value) {
                        setState(() => _isNotificationEnabled = value);
                      },
                    ),
                    _buildMenuItem(
                      Icons.language_rounded,
                      'Ngôn ngữ',
                      trailingText: 'Tiếng Việt',
                    ),
                    _buildToggleItem(
                      Icons.dark_mode_outlined,
                      'Chế độ tối',
                      _isDarkModeEnabled,
                      (value) {
                        setState(() => _isDarkModeEnabled = value);
                      },
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
      bottomNavigationBar: const CustomBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }

  String? _getKycSubtitle() {
    final status = _kycController.status?.toUpperCase();
    if (status == 'APPROVED') return 'Đã xác thực';
    if (status == 'PENDING') return 'Đang chờ duyệt';
    if (status == 'REJECTED') return 'Bị từ chối - Nhấn để thử lại';
    return 'Chưa xác thực';
  }

  Widget _buildProfileHeader() {
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
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
            if (_kycController.status?.toUpperCase() == 'APPROVED')
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
        const Text(
          'Lê Anh Tuấn',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'tuana.le@rebid.luxury',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1C1E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12, 
                color: subtitle.contains('từ chối') ? Colors.red : Colors.grey
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
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
      onTap: onTap,
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
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1C1E),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, color: Colors.purple, size: 12),
          SizedBox(width: 4),
          Text(
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
        label: const Text(
          'Đăng xuất',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
