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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Status Dot
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(18),
                    image: user.avatar != null
                        ? DecorationImage(
                            image: NetworkImage(user.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.avatar == null
                      ? Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Color(0xFF4F7DFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : null,
                ),
                if (user.accountStatus == AccountStatus.active)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                  Text(
                    user.email ?? 'Chưa có email', // Xử lý lỗi null ở đây
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildStatusBadge(
                        text: _getKycText(user.kycStatus),
                        color: _getKycColor(user.kycStatus),
                        isKyc: true,
                      ),
                      _buildStatusBadge(
                        text: user.accountStatus == AccountStatus.active ? 'HOẠT ĐỘNG' : 'BỊ KHÓA',
                        color: user.accountStatus == AccountStatus.active 
                            ? const Color(0xFF22C55E) 
                            : const Color(0xFF64748B),
                        isKyc: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required String text, required Color color, required bool isKyc}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isKyc ? 'KYC: $text' : text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getKycText(KycStatus status) {
    switch (status) {
      case KycStatus.verified: return 'ĐÃ DUYỆT';
      case KycStatus.pending: return 'CHỜ DUYỆT';
      case KycStatus.unverified: return 'TỪ CHỐI';
    }
  }

  Color _getKycColor(KycStatus status) {
    switch (status) {
      case KycStatus.verified: return const Color(0xFF2563EB);
      case KycStatus.pending: return const Color(0xFFDB2777);
      case KycStatus.unverified: return const Color(0xFFEF4444);
    }
  }
}
