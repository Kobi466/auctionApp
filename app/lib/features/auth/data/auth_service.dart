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

    final apiResponse = ApiResponse<TokenResponse>.fromJson(
      _responseBody(response),
      (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );

    if (_isSuccessful(response) && apiResponse.isSuccess) {
      return apiResponse;
    }

    throw Exception(
      _extractErrorMessage(
      statusCode: _statusCode(response),
      apiMessage: apiResponse.message,
      rawBody: _rawBody(response),
      fallbackMessage: 'Dang nhap that bai',
    ));
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
    final body = _responseBody(response);

    if (_isSuccessful(response)) {
      // Backend register endpoint currently returns a plain UserResponse,
      // while error cases are wrapped in ApiResponse.
      if (body.containsKey('result') || body.containsKey('code')) {
        return ApiResponse<UserResponse>.fromJson(
          body,
          (json) => UserResponse.fromJson(json as Map<String, dynamic>),
        );
      }

      return ApiResponse<UserResponse>(
        code: 1000,
        message: '',
        result: UserResponse.fromJson(body),
      );
    }

    final apiResponse = ApiResponse<UserResponse>.fromJson(body, null);

    throw Exception(_extractErrorMessage(
      statusCode: _statusCode(response),
      apiMessage: apiResponse.message,
      rawBody: _rawBody(response),
      fallbackMessage: 'Dang ky that bai',
    ));
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

    final apiResponse = ApiResponse<void>.fromJson(_responseBody(response), null);

    if (_isSuccessful(response) && apiResponse.isSuccess) {
      return;
    }

    throw Exception(_extractErrorMessage(
      statusCode: _statusCode(response),
      apiMessage: apiResponse.message,
      rawBody: _rawBody(response),
      fallbackMessage: 'Dang xuat that bai',
    ));
  }

  int _statusCode(Map<String, dynamic> response) {
    return response['statusCode'] as int? ?? 0;
  }

  Map<String, dynamic> _responseBody(Map<String, dynamic> response) {
    return response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  String _rawBody(Map<String, dynamic> response) {
    return response['rawBody']?.toString() ?? '';
  }

  bool _isSuccessful(Map<String, dynamic> response) {
    final statusCode = _statusCode(response);
    return statusCode >= 200 && statusCode < 300;
  }

  String _extractErrorMessage({
    required int statusCode,
    required String apiMessage,
    required String rawBody,
    required String fallbackMessage,
  }) {
    if (apiMessage.isNotEmpty) {
      return apiMessage;
    }
    if (rawBody.isNotEmpty) {
      return 'HTTP $statusCode: $rawBody';
    }
    return fallbackMessage;
  }
}
