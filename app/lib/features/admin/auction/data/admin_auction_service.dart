import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../home/data/models/product_model.dart';

class AdminAuctionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getAuctionRooms({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/auction-rooms',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<ProductModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Khong tai duoc danh sach phong dau gia',
    );
  }

  Future<ProductModel> createAuctionRoom({
    required String accessToken,
    required String productId,
    required num minimumBid,
    required num depositAmount,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await _apiClient.post(
      '/auction-rooms',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'productId': productId,
        'minimumBid': minimumBid,
        'depositAmount': depositAmount,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      body,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data!;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Khong tao duoc phong dau gia',
    );
  }

  Future<ProductModel> cancelAuctionRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _apiClient.put(
      '/auction-rooms/$roomId/cancel',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      body,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data!;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Khong huy duoc phien dau gia',
    );
  }
}
