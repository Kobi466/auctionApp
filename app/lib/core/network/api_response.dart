class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json)? fromJsonT,
      ) {
    return ApiResponse<T>(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  bool get isSuccess => status >= 200 && status < 300;
}