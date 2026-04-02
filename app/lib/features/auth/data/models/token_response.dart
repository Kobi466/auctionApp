import '../../../../core/models/base_model.dart';

class TokenResponse extends BaseModel {
  final String accessToken;
  final String refreshToken;
  final String? accessExpiresAt;
  final String? refreshExpiresAt;
  final String? accessIssuedAt;
  final String? refreshIssuedAt;
  final int accessExpirationTime;
  final int refreshExpirationTime;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpirationTime,
    required this.refreshExpirationTime,
    this.accessExpiresAt,
    this.refreshExpiresAt,
    this.accessIssuedAt,
    this.refreshIssuedAt,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      accessExpiresAt: json['accessExpiresAt']?.toString(),
      refreshExpiresAt: json['refreshExpiresAt']?.toString(),
      accessIssuedAt: json['accessIssuedAt']?.toString(),
      refreshIssuedAt: json['refreshIssuedAt']?.toString(),
      accessExpirationTime: json['accessExpirationTime'] ?? 0,
      refreshExpirationTime: json['refreshExpirationTime'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessExpiresAt': accessExpiresAt,
      'refreshExpiresAt': refreshExpiresAt,
      'accessIssuedAt': accessIssuedAt,
      'refreshIssuedAt': refreshIssuedAt,
      'accessExpirationTime': accessExpirationTime,
      'refreshExpirationTime': refreshExpirationTime,
    };
  }
}