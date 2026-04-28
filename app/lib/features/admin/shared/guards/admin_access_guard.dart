import 'package:flutter/material.dart';

import '../../../auth/data/auth_session.dart';
import '../../../auth/presentation/pages/login_screen.dart';

void ensureAdminAccess(BuildContext context) {
  final session = AuthSession.instance;
  if (session.isAuthenticated && session.isAdmin) {
    return;
  }

  session.clear();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}
