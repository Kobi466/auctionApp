enum KycStatus { verified, pending, unverified }
enum AccountStatus { active, locked }

class AdminUserEntity {
  final String id;
  final String name;
  final String role;
  final KycStatus kycStatus;
  final AccountStatus accountStatus;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? cccd;
  final String? dob;
  final String? address;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.kycStatus,
    required this.accountStatus,
    this.avatar,
    this.email,
    this.phone,
    this.cccd,
    this.dob,
    this.address,
  });
}
