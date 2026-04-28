import '../../../core/network/api_response.dart';
import '../data/auth_service.dart';
import '../data/models/token_response.dart';
import '../data/models/user_response.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<ApiResponse<TokenResponse>> login({
    required String email,
    required String password,
  }) async {
    return authService.login(
      email: email,
      password: password,
    );
  }

  Future<ApiResponse<UserResponse>> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    return authService.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  Future<void> logout({
    required String token,
  }) async {
    return authService.logout(token: token);
  }
}
