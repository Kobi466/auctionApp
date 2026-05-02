import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/winner_model.dart';

class AdminWinnerService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WinnerModel>> getWinners({
    required String accessToken,
    String? query,
    String? status,
  }) async {
    final Map<String, String> queryParameters = {};
    if (query != null && query.isNotEmpty) {
      queryParameters['search'] = query;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _apiClient.get(
      '/admin/winners', // Giả định endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      // queryParameters: queryParameters, // Giả định ApiClient hỗ trợ queryParams
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<WinnerModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => WinnerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải danh sách người thắng ($statusCode)',
    );
  }
}
