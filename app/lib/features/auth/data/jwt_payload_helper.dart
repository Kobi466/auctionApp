import 'dart:convert';

class JwtPayloadHelper {
  JwtPayloadHelper._();

  static Map<String, dynamic> decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return const <String, dynamic>{};
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return const <String, dynamic>{};
    }

    return const <String, dynamic>{};
  }

  static List<String> scopes(String token) {
    final payload = decodePayload(token);
    final rawScope = payload['scope']?.toString().trim() ?? '';
    if (rawScope.isEmpty) {
      return const <String>[];
    }

    return rawScope
        .split(RegExp(r'\s+'))
        .where((scope) => scope.isNotEmpty)
        .toList();
  }

  static bool hasScope(String token, String scope) {
    return scopes(token).contains(scope);
  }
}
