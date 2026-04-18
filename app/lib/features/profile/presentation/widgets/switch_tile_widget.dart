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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: Colors.white),
      title: Text(widget.title,
          style: const TextStyle(color: Colors.white)),
      subtitle: widget.subtitle != null
          ? Text(widget.subtitle!,
          style: const TextStyle(color: Colors.grey))
          : null,
      trailing: Switch(
        value: isOn,
        activeColor: Colors.amber,
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