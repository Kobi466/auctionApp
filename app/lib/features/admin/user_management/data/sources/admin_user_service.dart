import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/admin_user_model.dart';

class AdminUserService {
  final ApiClient _apiClient;

  AdminUserService(this._apiClient);

  Future<List<AdminUserModel>> getUsers({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/admin/users',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int? ?? 0;
    final Map<String, dynamic> body =
        response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final apiResponse = ApiResponse<List<AdminUserModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => AdminUserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Khong the tai danh sach nguoi dung',
    );
  }

  Future<AdminUserModel> updateUserStatus({
    required String accessToken,
    required String userId,
    required bool active,
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/admin/users/$userId/status',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'active': active,
        'reason': reason,
      },
    );

    final int statusCode = response['statusCode'] as int? ?? 0;
    final Map<String, dynamic> body =
        response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final apiResponse = ApiResponse<AdminUserModel>.fromJson(
      body,
      (json) => AdminUserModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 &&
        statusCode < 300 &&
        apiResponse.isSuccess &&
        apiResponse.data != null) {
      return apiResponse.data!;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Khong cap nhat duoc trang thai tai khoan',
    );
  }

  Future<void> sendNotification({
    required String accessToken,
    required String userId,
    required String title,
    required String message,
    String type = 'ADMIN_MESSAGE',
  }) async {
    final response = await _apiClient.post(
      '/admin/users/$userId/notifications',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'title': title,
        'message': message,
        'type': type,
      },
    );

    final int statusCode = response['statusCode'] as int? ?? 0;
    final Map<String, dynamic> body =
        response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final apiResponse = ApiResponse<void>.fromJson(body, null);

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Khong gui duoc thong bao',
    );
  }
}
