import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/auction_room_access_model.dart';
import 'models/auction_room_summary_model.dart';
import 'models/auction_payment_config_model.dart';
import 'models/bid_model.dart';

class AuctionRoomService {
  final ApiClient _apiClient = ApiClient();

  Future<AuctionRoomSummaryModel> getRoomSummary({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _apiClient.get(
      '/auction-rooms/$roomId/summary',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionRoomSummaryModel>.fromJson(
      body,
      (json) => AuctionRoomSummaryModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final summary = apiResponse.data;
      if (summary != null) return summary;
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong tai duoc phong dau gia',
      ),
    );
  }

  Future<List<AuctionRoomSummaryModel>> getMyWinnerPayments({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/auction-rooms/winner-payments/me',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<List<AuctionRoomSummaryModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) =>
                AuctionRoomSummaryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong tai duoc san pham da thang',
      ),
    );
  }

  Future<AuctionPaymentConfigModel> getActivePaymentConfig({
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
      final config = apiResponse.data;
      if (config != null) return config;
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong tai duoc thong tin chuyen khoan',
      ),
    );
  }

  Future<AuctionRoomAccessModel> joinAuctionRoom({
    required String accessToken,
    required String roomCode,
    required String roomPassword,
  }) async {
    final response = await _apiClient.post(
      '/auction-rooms/join',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'roomCode': roomCode, 'roomPassword': roomPassword},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionRoomAccessModel>.fromJson(
      body,
      (json) => AuctionRoomAccessModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final access = apiResponse.data;
      if (access != null) return access;
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong vao duoc phong dau gia',
      ),
    );
  }

  Future<BidModel> placeBid({
    required String accessToken,
    required String roomId,
    required num amount,
  }) async {
    final response = await _apiClient.post(
      '/auction-rooms/$roomId/bids',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'amount': amount},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<BidModel>.fromJson(
      body,
      (json) => BidModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final bid = apiResponse.data;
      if (bid != null) return bid;
    }

    throw Exception(
      _message(apiResponse.message, rawBody, statusCode, 'Khong dat gia duoc'),
    );
  }

  Future<AuctionRoomSummaryModel> submitWinnerPayment({
    required String accessToken,
    required String roomId,
    required String paymentMethod,
    String? shippingAddress,
    String? receiptUrl,
    String? userNote,
  }) async {
    final response = await _apiClient.put(
      '/auction-rooms/$roomId/winner-payment',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'paymentMethod': paymentMethod,
        'shippingAddress': shippingAddress,
        'receiptUrl': receiptUrl,
        'userNote': userNote,
      },
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionRoomSummaryModel>.fromJson(
      body,
      (json) => AuctionRoomSummaryModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final summary = apiResponse.data;
      if (summary != null) return summary;
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong gui duoc bien lai thanh toan',
      ),
    );
  }

  Future<AuctionRoomSummaryModel> acceptWinnerOffer({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _apiClient.put(
      '/auction-rooms/$roomId/winner-offer/accept',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final statusCode = response['statusCode'] as int;
    final body = response['body'] as Map<String, dynamic>;
    final rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<AuctionRoomSummaryModel>.fromJson(
      body,
      (json) => AuctionRoomSummaryModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      final summary = apiResponse.data;
      if (summary != null) return summary;
    }

    throw Exception(
      _message(
        apiResponse.message,
        rawBody,
        statusCode,
        'Khong xac nhan duoc loi moi nhan san pham',
      ),
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
