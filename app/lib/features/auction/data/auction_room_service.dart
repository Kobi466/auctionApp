import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/bid_model.dart';

class AuctionRoomService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BidModel>> getBidHistory(String roomId) async {
    final response = await _apiClient.get('/auction-rooms/$roomId/bids');
    final body = response['body'] as Map<String, dynamic>;
    final apiResponse = ApiResponse<List<BidModel>>.fromJson(
      body,
      (json) => (json as List).map((e) => BidModel.fromJson(e)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<bool> placeBid({
    required String roomId,
    required num amount,
    bool isAuto = false,
  }) async {
    final response = await _apiClient.post(
      '/auction-rooms/$roomId/place-bid',
      body: {'amount': amount, 'isAuto': isAuto},
    );
    final body = response['body'] as Map<String, dynamic>;
    return body['success'] == true;
  }
}
