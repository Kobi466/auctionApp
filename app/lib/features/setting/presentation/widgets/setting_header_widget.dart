import 'package:app/core/localization/app_translator.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String fullName;
  final String email;
  final String? avatar;
  final String? bio;
  final bool isVerified;

  const ProfileHeaderWidget({
    super.key,
    required this.fullName,
    required this.email,
    this.avatar,
    this.bio,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider(avatar);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(radius: 45, backgroundImage: imageProvider),
            if (isVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AppText(
          fullName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppText(email, style: TextStyle(color: colorScheme.primary)),
        AppText(
          (bio != null && bio!.trim().isNotEmpty) ? bio! : 'Elite Member',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.62)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  ImageProvider<Object> _buildImageProvider(String? avatarValue) {
    final normalized = avatarValue?.trim() ?? '';
    if (normalized.isEmpty) {
      return const NetworkImage('https://i.pravatar.cc/150?img=3');
    }

    if (normalized.startsWith('data:image/')) {
      final commaIndex = normalized.indexOf(',');
      if (commaIndex != -1) {
        final base64Data = normalized.substring(commaIndex + 1);
        try {
          return MemoryImage(base64Decode(base64Data));
        } on FormatException {
          return const NetworkImage('https://i.pravatar.cc/150?img=3');
        }
      }
    }

    return NetworkImage(normalized);
  }
}
