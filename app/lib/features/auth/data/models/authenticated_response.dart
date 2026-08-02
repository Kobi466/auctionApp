import '../../../../core/models/base_model.dart';
import 'token_response.dart';
import 'user_response.dart';

class AuthenticatedResponse extends BaseModel {
  final UserResponse user;
  final TokenResponse token;

  AuthenticatedResponse({required this.user, required this.token});

  factory AuthenticatedResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticatedResponse(
      user: UserResponse.fromJson(json['user'] ?? {}),
      token: TokenResponse.fromJson(json['token'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token.toJson()};
  }
}
