import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/auction_deposit_model.dart';
import 'models/auction_participation_status_model.dart';
import 'models/auction_room_access_model.dart';

class AuctionParticipationService {
  final ApiClient _apiClient = ApiClient();

  Future<AuctionParticipationStatusModel> getStatus({
    required String accessToken,
    required String productId,
  }) async {
    final response = await _apiClient.get(
      '/auction-participation/products/$productId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return _parseStatusResponse(response, 'Không tải được trạng thái đăng ký');
  }

  Future<AuctionParticipationStatusModel> confirmRules({
    required String accessToken,
    required String productId,
  }) async {
    final response = await _apiClient.post(
      '/auction-participation/products/$productId/confirm-rules',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return _parseStatusResponse(response, 'Không xác nhận được quy định');
  }

  Future<AuctionDepositModel> submitPayment({
    required String accessToken,
    required String depositId,
  }) async {
    final response = await _apiClient.put(
      '/auction-participation/deposits/$depositId/submit-payment',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionDepositModel>.fromJson(
      body,
      (json) => AuctionDepositModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final deposit = apiResponse.data;
      if (deposit != null) return deposit;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Không gửi được xác nhận chuyển khoản'));
  }

  Future<List<AuctionDepositModel>> getMyDeposits({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/auction-participation/deposits/me',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<List<AuctionDepositModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => AuctionDepositModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Không tải được danh sách chờ duyệt'));
  }

  Future<AuctionRoomAccessModel> getRoomAccess({
    required String accessToken,
    required String productId,
  }) async {
    final response = await _apiClient.get(
      '/auction-participation/products/$productId/room-access',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionRoomAccessModel>.fromJson(
      body,
      (json) => AuctionRoomAccessModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final roomAccess = apiResponse.data;
      if (roomAccess != null) return roomAccess;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode,
        'Khong lay duoc thong tin vao phong'));
  }

  AuctionParticipationStatusModel _parseStatusResponse(
    Map<String, dynamic> response,
    String fallback,
  ) {
    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionParticipationStatusModel>.fromJson(
      body,
      (json) => AuctionParticipationStatusModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final status = apiResponse.data;
      if (status != null) return status;
    }

    throw Exception(_message(apiResponse.message, rawBody, statusCode, fallback));
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
