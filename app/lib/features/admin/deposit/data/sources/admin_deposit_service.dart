import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/admin_deposit_model.dart';

class AdminDepositService {
  final ApiClient _apiClient;

  const AdminDepositService(this._apiClient);

  Future<List<AdminDepositModel>> getDeposits({
    required String accessToken,
    String? status,
  }) async {
    final endpoint = status == null || status.isEmpty
        ? '/auction-participation/deposits'
        : '/auction-participation/deposits?status=$status';
    final response = await _apiClient.get(
      endpoint,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<List<AdminDepositModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => AdminDepositModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_message(
      apiResponse.message,
      rawBody,
      statusCode,
      'Khong tai duoc danh sach tien coc',
    ));
  }

  Future<AdminDepositModel> reviewDeposit({
    required String accessToken,
    required String depositId,
    required String status,
    String? adminNote,
  }) async {
    final response = await _apiClient.put(
      '/auction-participation/deposits/$depositId/review',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'status': status,
        'adminNote': adminNote,
      },
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AdminDepositModel>.fromJson(
      body,
      (json) => AdminDepositModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final deposit = apiResponse.data;
      if (deposit != null) return deposit;
    }

    throw Exception(_message(
      apiResponse.message,
      rawBody,
      statusCode,
      'Khong duyet duoc tien coc',
    ));
  }

  String _message(
    String apiMessage,
    String rawBody,
    int statusCode,
    String fallback,
  ) {
    if (apiMessage.isNotEmpty) return apiMessage;
    if (rawBody.isNotEmpty) return 'HTTP $statusCode: $rawBody';
    return fallback;
  }
}
