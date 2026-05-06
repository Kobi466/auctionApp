import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

ImageProvider appImageProvider(
  String? value, {
  String fallbackUrl = 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338',
}) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    return NetworkImage(fallbackUrl);
  }

  if (normalized.startsWith('data:image/')) {
    final commaIndex = normalized.indexOf(',');
    if (commaIndex > -1) {
      try {
        final bytes = base64Decode(normalized.substring(commaIndex + 1));
        return MemoryImage(Uint8List.fromList(bytes));
      } catch (_) {
        return NetworkImage(fallbackUrl);
      }
    }
  }

  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return NetworkImage(normalized);
  }

  return FileImage(File(normalized));
}
