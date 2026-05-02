import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback? onTap;

  const AdminUserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFEEF2FF),
                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Role
                  Text(
                    user.role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // KYC Badge
                  _buildBadge(
                    text: _getKycText(user.kycStatus),
                    backgroundColor: _getKycBgColor(user.kycStatus),
                    textColor: _getKycTextColor(user.kycStatus),
                  ),
                  const SizedBox(height: 6),
                  // Account Status Badge
                  _buildBadge(
                    text: _getAccountText(user.accountStatus),
                    backgroundColor: _getAccountBgColor(user.accountStatus),
                    textColor: _getAccountTextColor(user.accountStatus),
                  ),
                ],
              ),
            ),
            // Lock Icon
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: Container(
            //     padding: const EdgeInsets.all(6),
            //     decoration: BoxDecoration(
            //       color: user.accountStatus == AccountStatus.locked
            //           ? const Color(0xFFFEE2E2)
            //           : const Color(0xFFF1F5F9),
            //       shape: BoxShape.circle,
            //     ),
            //     child: Icon(
            //       user.accountStatus == AccountStatus.locked
            //           ? Icons.lock_rounded
            //           : Icons.lock_open_rounded,
            //       size: 16,
            //       color: user.accountStatus == AccountStatus.locked
            //           ? const Color(0xFFEF4444)
            //           : const Color(0xFF94A3B8),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getKycText(KycStatus status) {
    switch (status) {
      case KycStatus.verified:
        return 'ĐÃ DUYỆT KYC';
      case KycStatus.pending:
        return 'CHỜ DUYỆT KYC';
      case KycStatus.unverified:
        return 'CHƯA XÁC THỰC';
    }
  }

  Color _getKycBgColor(KycStatus status) {
    switch (status) {
      case KycStatus.verified:
        return const Color(0xFFDCFCE7);
      case KycStatus.pending:
        return const Color(0xFFFEF9C3);
      case KycStatus.unverified:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getKycTextColor(KycStatus status) {
    switch (status) {
      case KycStatus.verified:
        return const Color(0xFF16A34A);
      case KycStatus.pending:
        return const Color(0xFFCA8A04);
      case KycStatus.unverified:
        return const Color(0xFF64748B);
    }
  }

  String _getAccountText(AccountStatus status) {
    return status == AccountStatus.active ? 'HOẠT ĐỘNG' : 'BỊ KHÓA';
  }

  Color _getAccountBgColor(AccountStatus status) {
    return status == AccountStatus.active ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2);
  }

  Color _getAccountTextColor(AccountStatus status) {
    return status == AccountStatus.active ? const Color(0xFF2563EB) : const Color(0xFFEF4444);
  }
}
