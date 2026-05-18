import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class WinnerReceiptPreview extends StatelessWidget {
  final String receiptPath;
  final VoidCallback? onOpened;

  const WinnerReceiptPreview({
    super.key,
    required this.receiptPath,
    this.onOpened,
  });

  @override
  Widget build(BuildContext context) {
    final path = receiptPath.trim();
    if (path.isEmpty) return const SizedBox.shrink();

    final image = _buildImage(path, fit: BoxFit.cover);
    final type = _receiptType(path);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
              height: 58,
              child:
                  image ??
                  Container(
                    color: const Color(0xFFEFF6FF),
                    child: Icon(type.icon, color: AppColors.primaryBlue),
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bien lai da gui',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${type.label}: ${_fileName(path)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _openPreview(context, path),
            icon: Icon(type.icon, size: 18),
            label: const Text('Xem'),
          ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, String path) {
    final image = _buildImage(path, fit: BoxFit.contain);
    onOpened?.call();

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: image == null ? Colors.white : Colors.black,
          child: Stack(
            children: [
              if (image != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Center(child: image),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 72),
                  child: _ReceiptDetail(path: path, type: _receiptType(path)),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildImage(String path, {required BoxFit fit}) {
    if (path.startsWith('data:image/')) {
      final commaIndex = path.indexOf(',');
      if (commaIndex < 0) return null;
      final payload = path.substring(commaIndex + 1);
      return Image.memory(
        base64Decode(payload),
        fit: fit,
        errorBuilder: (_, __, ___) => _brokenImage(),
      );
    }

    final lower = path.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (!isImage) return null;

    final uri = Uri.tryParse(path);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isNetwork) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => _brokenImage(),
      );
    }

    final file = File(path);
    if (!file.existsSync()) return null;
    return Image.file(
      file,
      fit: fit,
      errorBuilder: (_, __, ___) => _brokenImage(),
    );
  }

  _ReceiptType _receiptType(String path) {
    final lower = path.toLowerCase();
    if (path.startsWith('data:image/') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return const _ReceiptType('Anh', Icons.image_outlined);
    }
    if (path.startsWith('data:application/pdf') || lower.endsWith('.pdf')) {
      return const _ReceiptType('PDF', Icons.picture_as_pdf_outlined);
    }
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return const _ReceiptType('Lien ket', Icons.open_in_new);
    }
    return const _ReceiptType('Ma giao dich', Icons.receipt_long_outlined);
  }

  Widget _brokenImage() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
    );
  }

  String _fileName(String path) {
    if (path.startsWith('data:image/')) {
      final mimeEnd = path.indexOf(';');
      final mime = mimeEnd > 5 ? path.substring(5, mimeEnd) : 'image';
      return 'bien-lai.$mime';
    }
    if (path.startsWith('data:application/pdf')) {
      return 'bien-lai.pdf';
    }
    final normalized = path.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    if (slash < 0 || slash == normalized.length - 1) return normalized;
    return normalized.substring(slash + 1);
  }
}

class _ReceiptType {
  final String label;
  final IconData icon;

  const _ReceiptType(this.label, this.icon);
}

class _ReceiptDetail extends StatelessWidget {
  final String path;
  final _ReceiptType type;

  const _ReceiptDetail({required this.path, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDataPdf = path.startsWith('data:application/pdf');
    final content = isDataPdf
        ? 'File PDF da duoc gui dang base64. Hay doi soat theo file/ma giao dich ben duoi.'
        : path;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(type.icon, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Xem bien lai ${type.label.toLowerCase()}',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 320),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(color: Color(0xFF334155), height: 1.35),
            ),
          ),
        ),
      ],
    );
  }
}
