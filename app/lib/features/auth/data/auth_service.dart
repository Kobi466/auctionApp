import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/token_response.dart';
import 'models/user_response.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<ApiResponse<TokenResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<TokenResponse>.fromJson(
      body,
      (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Dang nhap that bai',
    );
  }

  Future<ApiResponse<UserResponse>> register({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/users',
      body: {
        'email': email,
        'password': password,
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<UserResponse>.fromJson(
      body,
      (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300) {
      return apiResponse;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Dang ky that bai',
    );
  }

  Future<void> logout({
    required String token,
  }) async {
    final response = await apiClient.post(
      '/auth/logout',
      body: {
        'token': token,
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<void>.fromJson(body, null);

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Dang xuat that bai',
    );
  }
}
