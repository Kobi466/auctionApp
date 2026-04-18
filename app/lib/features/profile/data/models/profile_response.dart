class ProfileResponse {
  final String userId;
  final String? fullName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final bool isWalletActive;
  final String kycStatus;
  final String preferences;

  ProfileResponse({
    required this.userId,
    required this.email,
    required this.isWalletActive,
    required this.kycStatus,
    required this.preferences,
    this.fullName,
    this.phoneNumber,
    this.avatar,
    this.bio,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      avatar: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      isWalletActive: json['isWalletActive'] == true,
      kycStatus: json['kycStatus']?.toString() ?? 'PENDING',
      preferences: json['preferences']?.toString() ?? '{}',
    );
  }
}
