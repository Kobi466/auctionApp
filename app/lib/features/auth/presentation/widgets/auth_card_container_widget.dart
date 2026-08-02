import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthCardContainerWidget extends StatelessWidget {
  final Widget child;

  const AuthCardContainerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}
