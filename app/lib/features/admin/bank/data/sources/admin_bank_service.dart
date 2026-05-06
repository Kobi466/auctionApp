import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../auction/data/models/auction_payment_config_model.dart';

class AdminBankService {
  final ApiClient _apiClient;

  const AdminBankService(this._apiClient);

  Future<List<AuctionPaymentConfigModel>> getBanks({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/auction-payment-config/all',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    if (statusCode == 404) {
      final active = await _getActiveBank(accessToken: accessToken);
      return active == null ? const [] : [active];
    }

    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<List<AuctionPaymentConfigModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) =>
              AuctionPaymentConfigModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Khong tai duoc danh sach ngan hang'));
  }

  Future<AuctionPaymentConfigModel?> _getActiveBank({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/auction-payment-config',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionPaymentConfigModel>.fromJson(
      body,
      (json) =>
          AuctionPaymentConfigModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Khong tai duoc ngan hang active'));
  }

  Future<AuctionPaymentConfigModel> saveBank({
    required String accessToken,
    int? id,
    required Map<String, dynamic> body,
  }) async {
    final response = id == null
        ? await _apiClient.post(
            '/auction-payment-config',
            headers: {'Authorization': 'Bearer $accessToken'},
            body: body,
          )
        : await _apiClient.put(
            '/auction-payment-config/$id',
            headers: {'Authorization': 'Bearer $accessToken'},
            body: body,
          );

    final statusCode = response['statusCode'] as int;
    final responseBody = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionPaymentConfigModel>.fromJson(
      responseBody,
      (json) =>
          AuctionPaymentConfigModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final bank = apiResponse.data;
      if (bank != null) return bank;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Khong luu duoc ngan hang'));
  }

  Future<void> deleteBank({
    required String accessToken,
    required int id,
  }) async {
    final response = await _apiClient.delete(
      '/auction-payment-config/$id',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<void>.fromJson(body, null);

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Khong xoa duoc ngan hang'));
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
