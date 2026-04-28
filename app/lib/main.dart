import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/admin/auction/presentation/pages/admin_auction_list_page.dart';
import 'features/admin/auction/presentation/pages/admin_auction_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auction App',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
