import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.kycStatus,
    required super.accountStatus,
    super.avatar,
    super.email,
    super.phone,
    super.cccd,
    super.dob,
    super.address,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Thành viên',
      kycStatus: _parseKycStatus(json['kycStatus']),
      accountStatus: _parseAccountStatus(json['accountStatus']),
      avatar: json['avatar']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      cccd: json['cccd']?.toString(),
      dob: json['dob']?.toString(),
      address: json['address']?.toString(),
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
    final s = status?.toString().toLowerCase();
    if (s == 'locked' || s == 'bị khóa' || s == 'inactive') {
      return AccountStatus.locked;
    }
    return AccountStatus.active;
  }
}
