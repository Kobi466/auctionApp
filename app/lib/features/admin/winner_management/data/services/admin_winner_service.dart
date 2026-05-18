import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../models/winner_ranking_model.dart';
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

    final queryString = Uri(queryParameters: queryParameters).query;
    final endpoint = queryString.isEmpty
        ? '/admin/winners'
        : '/admin/winners?$queryString';

    final response = await _apiClient.get(
      endpoint,
      headers: {'Authorization': 'Bearer $accessToken'},
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
          : rawBody.isNotEmpty
          ? 'HTTP $statusCode: $rawBody'
          : 'Khong the tai danh sach nguoi thang',
    );
  }

  Future<List<WinnerRankingModel>> getWinnerRanking({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _apiClient.get(
      '/admin/winners/$roomId/ranking',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<WinnerRankingModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) => WinnerRankingModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_resolveError(apiResponse.message, rawBody, statusCode));
  }

  Future<void> sendOffer({
    required String accessToken,
    required String roomId,
    required int rank,
    required bool sendEmail,
  }) async {
    await _postRankAction(
      accessToken: accessToken,
      roomId: roomId,
      endpoint: 'offer',
      rank: rank,
      sendEmail: sendEmail,
    );
  }

  Future<void> forfeitRank({
    required String accessToken,
    required String roomId,
    required int rank,
    required bool sendEmail,
  }) async {
    await _postRankAction(
      accessToken: accessToken,
      roomId: roomId,
      endpoint: 'forfeit',
      rank: rank,
      sendEmail: sendEmail,
    );
  }

  Future<List<WinnerRankingModel>> refundRank({
    required String accessToken,
    required String roomId,
    required int rank,
  }) async {
    final response = await _apiClient.post(
      '/admin/winners/$roomId/refund',
      body: {'rank': rank},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<WinnerRankingModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) => WinnerRankingModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_resolveError(apiResponse.message, rawBody, statusCode));
  }

  Future<List<WinnerRankingModel>> refundLosingDeposits({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _apiClient.post(
      '/admin/winners/$roomId/refund-losing-deposits',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<WinnerRankingModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) => WinnerRankingModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_resolveError(apiResponse.message, rawBody, statusCode));
  }

  Future<List<WinnerRankingModel>> confirmWinnerPayment({
    required String accessToken,
    required String roomId,
    String? adminNote,
  }) async {
    return _postPaymentReview(
      accessToken: accessToken,
      roomId: roomId,
      endpoint: 'confirm',
      adminNote: adminNote,
    );
  }

  Future<List<WinnerRankingModel>> rejectWinnerPayment({
    required String accessToken,
    required String roomId,
    String? adminNote,
  }) async {
    return _postPaymentReview(
      accessToken: accessToken,
      roomId: roomId,
      endpoint: 'reject',
      adminNote: adminNote,
    );
  }

  Future<List<WinnerRankingModel>> _postPaymentReview({
    required String accessToken,
    required String roomId,
    required String endpoint,
    String? adminNote,
  }) async {
    final response = await _apiClient.post(
      '/admin/winners/$roomId/payment/$endpoint',
      body: {'adminNote': adminNote},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<List<WinnerRankingModel>>.fromJson(
      body,
      (json) => (json as List<dynamic>)
          .map(
            (item) => WinnerRankingModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return apiResponse.data ?? const [];
    }

    throw Exception(_resolveError(apiResponse.message, rawBody, statusCode));
  }

  Future<void> _postRankAction({
    required String accessToken,
    required String roomId,
    required String endpoint,
    required int rank,
    required bool sendEmail,
  }) async {
    final response = await _apiClient.post(
      '/admin/winners/$roomId/$endpoint',
      body: {'rank': rank, 'sendEmail': sendEmail},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';
    final apiResponse = ApiResponse<dynamic>.fromJson(body, (json) => json);

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return;
    }

    throw Exception(_resolveError(apiResponse.message, rawBody, statusCode));
  }

  String _resolveError(String message, String rawBody, int statusCode) {
    if (message.isNotEmpty) {
      return message;
    }
    if (rawBody.isNotEmpty) {
      return 'HTTP $statusCode: $rawBody';
    }
    return 'Khong the thuc hien thao tac';
  }
}
