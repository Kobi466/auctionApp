import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.kycStatus,
    required super.accountStatus,
    super.avatar,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Thành viên',
      kycStatus: _parseKycStatus(json['kycStatus']),
      accountStatus: _parseAccountStatus(json['accountStatus']),
      avatar: json['avatar']?.toString(),
    );
  }

  static KycStatus _parseKycStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'verified':
      case 'đã duyệt':
        return KycStatus.verified;
      case 'pending':
      case 'chờ duyệt':
        return KycStatus.pending;
      default:
        return KycStatus.unverified;
    }
  }

  static AccountStatus _parseAccountStatus(dynamic status) {
    if (status?.toString().toLowerCase() == 'locked' || status?.toString().toLowerCase() == 'bị khóa') {
      return AccountStatus.locked;
    }
    return AccountStatus.active;
  }
}
