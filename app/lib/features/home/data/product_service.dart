import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getProducts({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/products',
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
              : 'Khong tai duoc danh sach san pham',
    );
  }

  Future<ProductModel> createProduct({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post(
      '/products',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> responseBody =
        response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      responseBody,
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
              : 'Khong tao duoc san pham',
    );
  }

  Future<ProductModel> updateProduct({
    required String accessToken,
    required String productId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.put(
      '/products/$productId',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> responseBody =
        response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      responseBody,
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
              : 'Khong cap nhat duoc san pham',
    );
  }

  Future<void> deleteProduct({
    required String accessToken,
    required String productId,
  }) async {
    final response = await _apiClient.delete(
      '/products/$productId',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final int statusCode = response['statusCode'] as int;
    final Map<String, dynamic> body = response['body'] as Map<String, dynamic>;
    final String rawBody = response['rawBody']?.toString() ?? '';

    final apiResponse = ApiResponse<void>.fromJson(body, null);

    if (statusCode >= 200 && statusCode < 300 && apiResponse.isSuccess) {
      return;
    }

    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : rawBody.isNotEmpty
              ? 'HTTP $statusCode: $rawBody'
              : 'Khong xoa duoc san pham',
    );
  }
}
