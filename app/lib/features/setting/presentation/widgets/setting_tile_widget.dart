import 'package:flutter/material.dart';

class SettingTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool isVerified;

  const SettingTileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: isVerified
          ? const Icon(Icons.check_circle, color: Colors.amber)
          : trailingText != null
          ? Text(trailingText!,
          style: const TextStyle(color: Colors.amber))
          : const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}