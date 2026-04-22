class UserProfileEntity {
  final String fullName;
  final String email;
  final String avatarUrl;
  final double balance;
  final bool isVerified;

  UserProfileEntity({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.balance,
    required this.isVerified,
  });
}
