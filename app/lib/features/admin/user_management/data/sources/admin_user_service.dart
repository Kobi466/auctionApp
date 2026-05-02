import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/admin_user_model.dart';

class AdminUserService {
  final ApiClient _apiClient;

  AdminUserService(this._apiClient);

  Future<List<AdminUserModel>> getUsers({
    required String accessToken,
  }) async {
    // Giả định API endpoint là /admin/users
    final response = await _apiClient.get(
      '/admin/users',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;

    final apiResponse = ApiResponse<List<AdminUserModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => AdminUserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Không thể tải danh sách người dùng');
  }
}
