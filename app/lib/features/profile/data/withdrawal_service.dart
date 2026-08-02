import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/withdrawal_request_model.dart';

class WithdrawalService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WithdrawalRequestModel>> getMyWithdrawals({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/withdrawals/me',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return _parseList(response, 'Khong tai duoc lich su rut tien');
  }

  Future<WithdrawalRequestModel> createWithdrawal({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post(
      '/withdrawals',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
    );
    return _parseOne(response, 'Khong gui duoc yeu cau rut tien');
  }

  Future<List<WithdrawalRequestModel>> getWithdrawals({
    required String accessToken,
    String? status,
  }) async {
    final endpoint = status == null || status.isEmpty
        ? '/withdrawals'
        : '/withdrawals?status=$status';
    final response = await _apiClient.get(
      endpoint,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return _parseList(response, 'Khong tai duoc yeu cau rut tien');
  }

  Future<WithdrawalRequestModel> reviewWithdrawal({
    required String accessToken,
    required String withdrawalId,
    required String status,
    String? adminNote,
  }) async {
    final response = await _apiClient.put(
      '/withdrawals/$withdrawalId/review',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'status': status,
        if (adminNote != null && adminNote.trim().isNotEmpty)
          'adminNote': adminNote.trim(),
      },
    );
    return _parseOne(response, 'Khong cap nhat duoc yeu cau rut tien');
  }

  List<WithdrawalRequestModel> _parseList(
    Map<String, dynamic> response,
    String fallback,
  ) {
    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<List<WithdrawalRequestModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) =>
                WithdrawalRequestModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }
    throw Exception(
      _message(apiResponse.message, rawBody, statusCode, fallback),
    );
  }

  WithdrawalRequestModel _parseOne(
    Map<String, dynamic> response,
    String fallback,
  ) {
    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<WithdrawalRequestModel>.fromJson(
      body,
      (json) => WithdrawalRequestModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final withdrawal = apiResponse.data;
      if (withdrawal != null) return withdrawal;
    }
    throw Exception(
      _message(apiResponse.message, rawBody, statusCode, fallback),
    );
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
