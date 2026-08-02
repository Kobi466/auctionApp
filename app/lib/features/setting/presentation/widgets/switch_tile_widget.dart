import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

class SwitchTileWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool)? onChanged;

  const SwitchTileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  State<SwitchTileWidget> createState() => _SwitchTileWidgetState();
}

class _SwitchTileWidgetState extends State<SwitchTileWidget> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  @override
  void didUpdateWidget(covariant SwitchTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      isOn = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(widget.icon, color: colorScheme.onSurface),
      title: AppText(
        widget.title,
        style: TextStyle(color: colorScheme.onSurface),
      ),
      subtitle: widget.subtitle != null
          ? AppText(
              widget.subtitle!,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.62)),
            )
          : null,
      trailing: Switch(
        value: isOn,
        activeColor: colorScheme.primary,
        onChanged: (value) {
          setState(() {
            isOn = value;
          });

          widget.onChanged?.call(value);
        },
      ),
    );
  }
}
