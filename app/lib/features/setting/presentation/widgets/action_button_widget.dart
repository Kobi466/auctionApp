import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final bool isOutlined;
  final VoidCallback? onPressed;

  const ActionButtonWidget({
    super.key,
    required this.text,
    required this.color,
    this.isOutlined = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
              onPressed: onPressed,
              child: AppText(text, style: TextStyle(color: color)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: onPressed,
              child: AppText(text),
            ),
    );
  }
}
