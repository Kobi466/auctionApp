import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/kyc_request_model.dart';
import 'models/kyc_response_model.dart';

class KycService {
  final ApiClient _apiClient = ApiClient();

  Future<KycResponseModel?> getMyKyc({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/kyc-details/me',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final statusCode = response['statusCode'] as int? ?? 0;
    final body = response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final rawBody = response['rawBody']?.toString() ?? '';

    if (statusCode == 404) {
      return null;
    }

    final apiResponse = ApiResponse<KycResponseModel>.fromJson(
      body,
      (json) => KycResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
          ? 'HTTP $statusCode: $rawBody'
          : 'Khong tai duoc thong tin KYC',
    );
  }

  Future<KycResponseModel> submitKyc({
    required String accessToken,
    required KycRequestModel request,
  }) async {
    final response = await _apiClient.post(
      '/kyc-details/me',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: request.toJson(),
    );

    final statusCode = response['statusCode'] as int? ?? 0;
    final body = response['body'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<KycResponseModel>.fromJson(
      body,
      (json) => KycResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final data = apiResponse.data;
      if (data != null) {
        return data;
      }
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
          ? 'HTTP $statusCode: $rawBody'
          : 'Gui KYC that bai',
    );
  }
}
