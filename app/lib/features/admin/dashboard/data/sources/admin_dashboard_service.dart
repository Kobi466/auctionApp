import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/admin_dashboard_summary_model.dart';

class AdminDashboardService {
  final ApiClient apiClient;

  AdminDashboardService(this.apiClient);

  Future<AdminDashboardSummaryModel> getDashboardSummary({
    required String accessToken,
  }) async {
    final response = await apiClient.get(
      '/admin/dashboard-summary',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final apiResponse = ApiResponse<AdminDashboardSummaryModel>.fromJson(
      _responseBody(response),
      (json) => AdminDashboardSummaryModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );

    if (_isSuccessful(response) && apiResponse.isSuccess && apiResponse.data != null) {
      return apiResponse.data!;
    }

    throw Exception(
      _extractErrorMessage(
        statusCode: _statusCode(response),
        apiMessage: apiResponse.message,
        rawBody: _rawBody(response),
        fallbackMessage: 'Không tải được thống kê admin',
      ),
    );
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
