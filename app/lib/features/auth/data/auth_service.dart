import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/authenticated_response.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<ApiResponse<AuthenticatedResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final int statusCode = response['statusCode'];
    final Map<String, dynamic> body = response['body'];

    final apiResponse = ApiResponse<AuthenticatedResponse>.fromJson(
      body,
          (json) => AuthenticatedResponse.fromJson(json),
    );

    if (statusCode >= 200 && statusCode < 300) {
      return apiResponse;
    }

    throw Exception(apiResponse.message.isNotEmpty
        ? apiResponse.message
        : 'Đăng nhập thất bại');
  }
}