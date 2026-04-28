import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8081/auction';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8081/auction';
      default:
        return 'http://127.0.0.1:8081/auction';
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
          )
          .timeout(const Duration(seconds: 15));

      return _buildResponse(response);
    } catch (_) {
      throw Exception(_buildConnectionError(uri));
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 15));

      return _buildResponse(response);
    } catch (_) {
      throw Exception(_buildConnectionError(uri));
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 15));

      return _buildResponse(response);
    } catch (_) {
      throw Exception(_buildConnectionError(uri));
    }
  }

  String _buildConnectionError(Uri uri) {
    if (defaultTargetPlatform == TargetPlatform.android &&
        _configuredBaseUrl.isEmpty) {
      return 'Khong ket noi duoc toi server: $uri. '
          'Neu dang chay tren dien thoai cam USB, hay chay: '
          '`adb reverse tcp:8081 tcp:8081` '
          'hoac dung `--dart-define=API_BASE_URL=http://IP_MAY_TINH:8081/auction`.';
    }

    return 'Khong ket noi duoc toi server: $uri';
  }

  Map<String, dynamic> _buildResponse(http.Response response) {
    Map<String, dynamic> parsedBody = {};
    final rawBody = response.body;

    if (rawBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBody);
        if (decoded is Map<String, dynamic>) {
          parsedBody = decoded;
        }
      } on FormatException {
        parsedBody = {};
      }
    }

    return {
      'statusCode': response.statusCode,
      'body': parsedBody,
      'rawBody': rawBody,
    };
  }
}
