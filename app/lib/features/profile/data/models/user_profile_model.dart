import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  UserProfileModel({
    required super.fullName,
    required super.email,
    required super.avatarUrl,
    required super.balance,
    required super.isVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'balance': balance,
      'is_verified': isVerified,
    };
  }
}
