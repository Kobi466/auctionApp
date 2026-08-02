import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;

  const SectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.62);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(title, style: TextStyle(color: color)),
      ),
    );
  }
}
