import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/user_kyc_status_card.dart';

class AdminUserProfilePage extends StatelessWidget {
  final AdminUserEntity user;

  const AdminUserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hồ sơ người dùng',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            UserProfileHeader(user: user),
            const SizedBox(height: 24),
            UserKycStatusCard(user: user),
            const SizedBox(height: 32),
            _buildActionButton(
              onPressed: () {},
              icon: Icons.send_rounded,
              label: 'Gửi thông báo',
              color: const Color(0xFF0052FF),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              onPressed: () {},
              icon: Icons.block_flipped,
              label: 'Khóa tài khoản',
              color: const Color(0xFFFEE2E2),
              textColor: const Color(0xFFDC2626),
              isOutline: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isOutline ? BorderSide(color: color) : BorderSide.none,
          ),
        ),
        icon: Icon(icon, color: textColor, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
