import '../../../core/network/api_response.dart';
import '../data/auth_service.dart';
import '../data/models/authenticated_response.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<ApiResponse<AuthenticatedResponse>> login({
    required String email,
    required String password,
  }) async {
    return authService.login(
      email: email,
      password: password,
    );
  }
}