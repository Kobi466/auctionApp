import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  final localeController = LocaleController();
  await Future.wait([
    themeController.load(),
    localeController.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: localeController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, LocaleController>(
      builder: (context, themeController, localeController, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Auction App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const LoginScreen(),
        );
      },
    );
  }
}
