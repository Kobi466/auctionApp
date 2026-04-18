import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8081/auction';

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
    );

    return _buildResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );

    return _buildResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );

    return _buildResponse(response);
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
