import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auction Login',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}