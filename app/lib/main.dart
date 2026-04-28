import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/kyc/presentation/pages/kyc_main_page.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
// import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/admin/overview/presentation/pages/admin_dashboard_page.dart';
import 'features/admin/kyc/presentation/pages/kyc_approval_list_page.dart';
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
      home: const KycApprovalListPage(),
    );
  }
}
