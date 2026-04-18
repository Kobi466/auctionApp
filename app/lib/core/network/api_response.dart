class ApiResponse<T> {
  final int code;
  final String message;
  final T? result;

  ApiResponse({
    required this.code,
    required this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      result: json['result'] != null && fromJsonT != null
          ? fromJsonT(json['result'])
          : null,
    );
  }

  T? get data => result;

  bool get isSuccess => code == 0 || code == 1000;
}
