import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';

class UserKycStatusCard extends StatelessWidget {
  final AdminUserEntity user;

  const UserKycStatusCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái xác thực',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              _buildKycBadge(user.kycStatus),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoItem('SỐ CCCD', user.cccd ?? 'Chưa có')),
              Expanded(child: _buildInfoItem('NGÀY SINH', user.dob ?? 'Chưa có')),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoItem('ĐỊA CHỈ', user.address ?? 'Chưa cập nhật'),
        ],
      ),
    );
  }

  Widget _buildKycBadge(KycStatus status) {
    final bool isVerified = status == KycStatus.verified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle_outline : Icons.error_outline,
            size: 14,
            color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Đã duyệt KYC' : 'Chưa xác thực',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
