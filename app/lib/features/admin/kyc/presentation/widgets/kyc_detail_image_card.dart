import 'dart:convert';

import 'package:flutter/material.dart';

class KycDetailImageCard extends StatelessWidget {
  final String label;
  final String imageValue;
  final bool fullWidth;

  const KycDetailImageCard({
    super.key,
    required this.label,
    required this.imageValue,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = imageValue.trim();

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImagePreview(
              normalized,
              height: fullWidth ? 200 : 120,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String value, {required double height}) {
    if (value.isEmpty) {
      return _buildImagePlaceholder(height);
    }

    if (value.startsWith('data:image/')) {
      final commaIndex = value.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(value.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildImagePlaceholder(height),
          );
        } on FormatException {
          return _buildImagePlaceholder(height);
        }
      }
    }

    return Image.network(
      value,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildImagePlaceholder(height),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey),
      ),
    );
  }
}
