import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080';

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

    Map<String, dynamic> parsedBody = {};

    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        parsedBody = decoded;
      }
    }

    return {
      'statusCode': response.statusCode,
      'body': parsedBody,
    };
  }
}