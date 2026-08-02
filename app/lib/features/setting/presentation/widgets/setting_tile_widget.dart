import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

class SettingTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool isVerified;
  final VoidCallback? onTap;

  const SettingTileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = colorScheme.onSurface.withOpacity(0.62);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colorScheme.onSurface),
      title: AppText(title, style: TextStyle(color: colorScheme.onSurface)),
      subtitle: subtitle != null
          ? AppText(subtitle!, style: TextStyle(color: mutedColor))
          : null,
      trailing: isVerified
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : trailingText != null
          ? AppText(trailingText!, style: TextStyle(color: colorScheme.primary))
          : Icon(Icons.arrow_forward_ios, size: 14, color: mutedColor),
    );
  }
}
