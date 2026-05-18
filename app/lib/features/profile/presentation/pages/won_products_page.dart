import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auction/data/auction_room_service.dart';
import '../../../auction/data/models/auction_room_summary_model.dart';
import '../../../auth/data/auth_session.dart';
import '../../../admin/winner_management/presentation/widgets/winner_receipt_preview.dart';

class WonProductsPage extends StatefulWidget {
  const WonProductsPage({super.key});

  @override
  State<WonProductsPage> createState() => _WonProductsPageState();
}

class _WonProductsPageState extends State<WonProductsPage> {
  final AuctionRoomService _service = AuctionRoomService();
  final Map<String, TextEditingController> _noteControllers = {};
  final Map<String, PlatformFile> _selectedReceipts = {};
  List<AuctionRoomSummaryModel> _items = const [];
  bool _isLoading = true;
  String? _error;
  String? _submittingRoomId;
  String? _acceptingRoomId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Khong tim thay access token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.getMyWinnerPayments(accessToken: token);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _pickReceipt(String roomId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || !mounted) return;
    setState(() => _selectedReceipts[roomId] = file);
  }

  Future<void> _submit(AuctionRoomSummaryModel item) async {
    final roomId = item.product.auctionRoom?.id ?? '';
    final token = AuthSession.instance.accessToken;
    if (roomId.isEmpty || token == null || token.isEmpty) {
      _showError('Khong tim thay phien thanh toan');
      return;
    }

    final receipt = _selectedReceipts[roomId];
    final note = _noteController(roomId).text.trim();
    if (receipt == null && note.isEmpty) {
      _showError('Chon tep bien lai hoac nhap ghi chu chuyen khoan');
      return;
    }

    setState(() => _submittingRoomId = roomId);
    try {
      await _service.submitWinnerPayment(
        accessToken: token,
        roomId: roomId,
        receiptUrl: receipt == null ? null : await _receiptReference(receipt),
        userNote: note.isEmpty ? null : note,
      );
      _noteController(roomId).clear();
      _selectedReceipts.remove(roomId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui bien lai cho admin')),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submittingRoomId = null);
    }
  }

  Future<void> _acceptOffer(AuctionRoomSummaryModel item) async {
    final roomId = item.product.auctionRoom?.id ?? '';
    final token = AuthSession.instance.accessToken;
    if (roomId.isEmpty || token == null || token.isEmpty) {
      _showError('Khong tim thay phien thanh toan');
      return;
    }

    setState(() => _acceptingRoomId = roomId);
    try {
      await _service.acceptWinnerOffer(accessToken: token, roomId: roomId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da dong y nhan san pham')));
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _acceptingRoomId = null);
    }
  }

  Future<String> _receiptReference(PlatformFile file) async {
    final path = file.path;
    if (path == null || path.isEmpty) {
      return file.name;
    }
    final bytes = await File(path).readAsBytes();
    final mimeType = _mimeType(file.extension);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  String _mimeType(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  TextEditingController _noteController(String roomId) {
    return _noteControllers.putIfAbsent(roomId, TextEditingController.new);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'San pham da thang',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _StateMessage(message: _error!, onRetry: _load)
            : _items.isEmpty
            ? const _StateMessage(message: 'Chua co san pham can thanh toan')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final roomId = item.product.auctionRoom?.id ?? '';
                  return _WonProductCard(
                    item: item,
                    selectedReceipt: _selectedReceipts[roomId],
                    noteController: _noteController(roomId),
                    isSubmitting: _submittingRoomId == roomId,
                    isAccepting: _acceptingRoomId == roomId,
                    onPickReceipt: () => _pickReceipt(roomId),
                    onAcceptOffer: () => _acceptOffer(item),
                    onSubmit: () => _submit(item),
                  );
                },
              ),
      ),
    );
  }
}

class _WonProductCard extends StatelessWidget {
  final AuctionRoomSummaryModel item;
  final PlatformFile? selectedReceipt;
  final TextEditingController noteController;
  final bool isSubmitting;
  final bool isAccepting;
  final VoidCallback onPickReceipt;
  final VoidCallback onAcceptOffer;
  final VoidCallback onSubmit;

  const _WonProductCard({
    required this.item,
    required this.selectedReceipt,
    required this.noteController,
    required this.isSubmitting,
    required this.isAccepting,
    required this.onPickReceipt,
    required this.onAcceptOffer,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final canSubmit =
        item.winnerPaymentStatus == 'WAITING_PAYMENT' ||
        item.winnerPaymentStatus == 'PAYMENT_REJECTED';
    final canAccept = item.winnerPaymentStatus == 'WAITING_ACCEPTANCE';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: product.displayImage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusPill(
                      label: _paymentLabel(item.winnerPaymentStatus),
                      color: _paymentColor(item.winnerPaymentStatus),
                    ),
                    if ((item.winnerPaymentRejectedCount ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Lan gui lai ${item.winnerPaymentRejectedCount}/3',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Hang ${item.currentWinnerRank ?? '-'}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatVnd(item.winnerPaymentAmount),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((item.winnerPaymentReceiptUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            WinnerReceiptPreview(
              receiptPath: item.winnerPaymentReceiptUrl ?? '',
            ),
          ],
          if (canAccept) ...[
            const SizedBox(height: 14),
            const Text(
              'Nguoi xep hang truoc da bi loai. Ban co muon nhan san pham voi gia da dau khong?',
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isAccepting ? null : onAcceptOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: isAccepting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Dong y nhan san pham',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
          if (canSubmit) ...[
            const SizedBox(height: 14),
            _ReceiptPicker(
              file: selectedReceipt,
              onPressed: isSubmitting ? null : onPickReceipt,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Ghi chu chuyen khoan',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text(
                  'Gui bien lai cho admin',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentLabel(String? status) {
    switch (status) {
      case 'WAITING_ACCEPTANCE':
        return 'Cho xac nhan';
      case 'WAITING_PAYMENT':
        return 'Cho thanh toan';
      case 'PAYMENT_SUBMITTED':
        return 'Cho admin doi soat';
      case 'PAYMENT_REJECTED':
        return 'Can gui lai';
      case 'PAID':
        return 'Da xac nhan';
      default:
        return 'Dang xu ly';
    }
  }

  Color _paymentColor(String? status) {
    switch (status) {
      case 'WAITING_ACCEPTANCE':
        return const Color(0xFF2563EB);
      case 'PAYMENT_SUBMITTED':
        return const Color(0xFFF59E0B);
      case 'PAYMENT_REJECTED':
        return const Color(0xFFEF4444);
      case 'PAID':
        return const Color(0xFF10B981);
      default:
        return AppColors.primaryBlue;
    }
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);
    final isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    final fileExists =
        normalizedUrl.isNotEmpty && File(normalizedUrl).existsSync();

    Widget placeholder() {
      return Container(
        width: 82,
        height: 82,
        color: const Color(0xFFEFF6FF),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primaryBlue,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 82,
        height: 82,
        child: isNetworkImage
            ? Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder(),
              )
            : fileExists
            ? Image.file(
                File(normalizedUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder(),
              )
            : placeholder(),
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  final PlatformFile? file;
  final VoidCallback? onPressed;

  const _ReceiptPicker({required this.file, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final selected = file != null;
    return Material(
      color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.upload_file_outlined,
                  color: selected ? Colors.white : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected ? file!.name : 'Chon tep bien lai',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selected
                          ? _formatFileSize(file!.size)
                          : 'Anh JPG, PNG hoac PDF',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'Da chon tep';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _StateMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.emoji_events_outlined,
          size: 48,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Tai lai'),
            ),
          ),
        ],
      ],
    );
  }
}
