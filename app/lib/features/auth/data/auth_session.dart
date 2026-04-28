import 'jwt_payload_helper.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  String? accessToken;
  String? refreshToken;
  List<String> roles = const [];
  bool? _isAdminOverride;

  bool get isAuthenticated {
    return (accessToken?.isNotEmpty ?? false) &&
        (refreshToken?.isNotEmpty ?? false);
  }

  bool get isAdmin {
    if (_isAdminOverride != null) {
      return _isAdminOverride!;
    }

    if (roles.contains('ADMIN')) {
      return true;
    }

    final token = accessToken;
    if (token == null || token.isEmpty) {
      return false;
    }

    return JwtPayloadHelper.hasScope(token, 'ROLE_ADMIN');
  }

  void save({
    required String accessToken,
    required String refreshToken,
    List<String> roles = const [],
    bool? isAdmin,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.roles = List<String>.unmodifiable(roles);
    _isAdminOverride = isAdmin;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
    roles = const [];
    _isAdminOverride = null;
  }
}
