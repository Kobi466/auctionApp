import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/profile_response.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<ProfileResponse> getProfile({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/profiles/me',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProfileResponse>.fromJson(
      body,
      (json) => ProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final profile = apiResponse.data;
      if (profile != null) {
        return profile;
      }
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Khong tai duoc profile',
    );
  }

  Future<ProfileResponse> updateProfile({
    required String accessToken,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String avatar,
  }) async {
    final response = await _apiClient.put(
      '/profiles/me',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatar': avatar,
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProfileResponse>.fromJson(
      body,
      (json) => ProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final profile = apiResponse.data;
      if (profile != null) {
        return profile;
      }
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Cap nhat profile that bai',
    );
  }
}
