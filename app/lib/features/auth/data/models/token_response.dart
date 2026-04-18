import '../../../../core/models/base_model.dart';

class TokenResponse extends BaseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final bool authenticated;
  final String? accessExpiresAt;
  final String? refreshExpiresAt;
  final String? accessIssuedAt;
  final String? refreshIssuedAt;
  final int accessExpirationTime;
  final int refreshExpirationTime;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.authenticated,
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
      tokenType: json['tokenType']?.toString() ?? '',
      authenticated: json['authenticated'] == true,
      accessExpiresAt: json['accessExpiresAt']?.toString(),
      refreshExpiresAt: json['refreshExpiresAt']?.toString(),
      accessIssuedAt: json['accessIssuedAt']?.toString(),
      refreshIssuedAt: json['refreshIssuedAt']?.toString(),
      accessExpirationTime:
          (json['accessExpirationTime'] ?? json['accessTokenExpiresIn'] ?? 0)
              as int,
      refreshExpirationTime:
          (json['refreshExpirationTime'] ?? json['refreshTokenExpiresIn'] ?? 0)
              as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'authenticated': authenticated,
      'accessExpiresAt': accessExpiresAt,
      'refreshExpiresAt': refreshExpiresAt,
      'accessIssuedAt': accessIssuedAt,
      'refreshIssuedAt': refreshIssuedAt,
      'accessExpirationTime': accessExpirationTime,
      'refreshExpirationTime': refreshExpirationTime,
    };
  }
}
