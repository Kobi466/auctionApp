import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auction/data/auction_room_service.dart';
import '../../../auction/data/models/auction_payment_config_model.dart';
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
  final Map<String, TextEditingController> _shippingAddressControllers = {};
  final Map<String, PlatformFile> _selectedReceipts = {};
  final Map<String, String> _selectedPaymentMethods = {};
  List<AuctionRoomSummaryModel> _items = const [];
  AuctionPaymentConfigModel? _paymentConfig;
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
    for (final controller in _shippingAddressControllers.values) {
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
      AuctionPaymentConfigModel? paymentConfig;
      try {
        paymentConfig = await _service.getActivePaymentConfig(
          accessToken: token,
        );
      } catch (_) {
        paymentConfig = null;
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _paymentConfig = paymentConfig;
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
    final shippingAddress = _shippingAddressController(roomId).text.trim();
    final paymentMethod = _selectedPaymentMethods[roomId] ?? 'BANK_TRANSFER';
    if (shippingAddress.isEmpty) {
      _showError('Nhap dia chi giao hang');
      return;
    }
    if (paymentMethod == 'BANK_TRANSFER' && receipt == null && note.isEmpty) {
      _showError('Chon tep bien lai hoac nhap ghi chu chuyen khoan');
      return;
    }

    setState(() => _submittingRoomId = roomId);
    try {
      await _service.submitWinnerPayment(
        accessToken: token,
        roomId: roomId,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        receiptUrl: paymentMethod == 'BANK_TRANSFER' && receipt != null
            ? await _receiptReference(receipt)
            : null,
        userNote: note.isEmpty ? null : note,
      );
      _noteController(roomId).clear();
      _shippingAddressController(roomId).clear();
      _selectedReceipts.remove(roomId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentMethod == 'COD'
                ? 'Da chon thanh toan khi nhan hang'
                : 'Da gui bien lai cho admin',
          ),
        ),
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

  TextEditingController _shippingAddressController(String roomId) {
    return _shippingAddressControllers.putIfAbsent(
      roomId,
      TextEditingController.new,
    );
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
                    selectedPaymentMethod:
                        _selectedPaymentMethods[roomId] ?? 'BANK_TRANSFER',
                    paymentConfig: _paymentConfig,
                    noteController: _noteController(roomId),
                    shippingAddressController: _shippingAddressController(
                      roomId,
                    ),
                    isSubmitting: _submittingRoomId == roomId,
                    isAccepting: _acceptingRoomId == roomId,
                    onPickReceipt: () => _pickReceipt(roomId),
                    onPaymentMethodChanged: (method) {
                      setState(() {
                        _selectedPaymentMethods[roomId] = method;
                        if (method == 'COD') {
                          _selectedReceipts.remove(roomId);
                        }
                      });
                    },
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
  final String selectedPaymentMethod;
  final AuctionPaymentConfigModel? paymentConfig;
  final TextEditingController noteController;
  final TextEditingController shippingAddressController;
  final bool isSubmitting;
  final bool isAccepting;
  final VoidCallback onPickReceipt;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onAcceptOffer;
  final VoidCallback onSubmit;

  const _WonProductCard({
    required this.item,
    required this.selectedReceipt,
    required this.selectedPaymentMethod,
    required this.paymentConfig,
    required this.noteController,
    required this.shippingAddressController,
    required this.isSubmitting,
    required this.isAccepting,
    required this.onPickReceipt,
    required this.onPaymentMethodChanged,
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
                    const Text(
                      'Con phai thanh toan',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
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
            _PaymentMethodSelector(
              selectedMethod: selectedPaymentMethod,
              onChanged: isSubmitting ? null : onPaymentMethodChanged,
            ),
            if (selectedPaymentMethod == 'BANK_TRANSFER') ...[
              const SizedBox(height: 12),
              _WinnerBankTransferBox(
                item: item,
                paymentConfig: paymentConfig,
              ),
              const SizedBox(height: 12),
              _ReceiptPicker(
                file: selectedReceipt,
                onPressed: isSubmitting ? null : onPickReceipt,
              ),
            ] else ...[
              const SizedBox(height: 12),
              const _CodInfoBox(),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: shippingAddressController,
              minLines: 2,
              maxLines: 4,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Dia chi giao hang',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryBlue,
                ),
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
            TextField(
              controller: noteController,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: selectedPaymentMethod == 'COD'
                    ? 'Ghi chu giao hang (khong bat buoc)'
                    : 'Ghi chu chuyen khoan',
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
                    : Icon(
                        selectedPaymentMethod == 'COD'
                            ? Icons.local_shipping_outlined
                            : Icons.cloud_upload_outlined,
                      ),
                label: const Text(
                  'Xac nhan thanh toan',
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

class _PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String>? onChanged;

  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PaymentMethodOption(
            icon: Icons.qr_code_2_rounded,
            title: 'Chuyen khoan',
            subtitle: 'Quet QR ngan hang',
            selected: selectedMethod == 'BANK_TRANSFER',
            onTap: onChanged == null
                ? null
                : () => onChanged!.call('BANK_TRANSFER'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PaymentMethodOption(
            icon: Icons.local_shipping_outlined,
            title: 'Nhan hang',
            subtitle: 'Thanh toan COD',
            selected: selectedMethod == 'COD',
            onTap: onChanged == null ? null : () => onChanged!.call('COD'),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBlue : const Color(0xFF64748B);
    return Material(
      color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinnerBankTransferBox extends StatelessWidget {
  final AuctionRoomSummaryModel item;
  final AuctionPaymentConfigModel? paymentConfig;

  const _WinnerBankTransferBox({
    required this.item,
    required this.paymentConfig,
  });

  @override
  Widget build(BuildContext context) {
    final config = paymentConfig;
    if (config == null) {
      return const _InfoPanel(
        icon: Icons.account_balance_outlined,
        title: 'Chua co thong tin ngan hang',
        message: 'Admin can cau hinh ngan hang active de hien QR.',
      );
    }

    final transferContent = _winnerTransferContent(config, item);
    final qrUrl = _buildWinnerVietQrUrl(
      paymentConfig: config,
      amount: item.winnerPaymentAmount ?? 0,
      transferContent: transferContent,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Center(
            child: qrUrl.isEmpty
                ? const Icon(
                    Icons.qr_code_2_rounded,
                    size: 156,
                    color: AppColors.primaryBlue,
                  )
                : Image.network(
                    qrUrl,
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.qr_code_2_rounded,
                      size: 156,
                      color: AppColors.primaryBlue,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _PaymentInfoRow(label: 'Ngan hang', value: config.bankName),
          _PaymentInfoRow(label: 'So tai khoan', value: config.accountNumber),
          _PaymentInfoRow(label: 'Chu tai khoan', value: config.accountHolderName),
          _PaymentInfoRow(
            label: 'Con lai',
            value: formatVnd(item.winnerPaymentAmount),
          ),
          _PaymentInfoRow(label: 'Noi dung', value: transferContent),
        ],
      ),
    );
  }
}

class _CodInfoBox extends StatelessWidget {
  const _CodInfoBox();

  @override
  Widget build(BuildContext context) {
    return const _InfoPanel(
      icon: Icons.local_shipping_outlined,
      title: 'Thanh toan khi nhan hang',
      message: 'Admin se xac nhan don va doi soat khi giao san pham.',
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 102,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
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

String _winnerTransferContent(
  AuctionPaymentConfigModel paymentConfig,
  AuctionRoomSummaryModel item,
) {
  final roomId = item.product.auctionRoom?.id ?? item.product.id;
  final prefix = (paymentConfig.transferNotePrefix?.trim().isNotEmpty == true
          ? paymentConfig.transferNotePrefix!.trim()
          : 'AUC')
      .toUpperCase();
  final shortRoomId = roomId.length > 8 ? roomId.substring(0, 8) : roomId;
  return '$prefix-WIN-$shortRoomId';
}

String _buildWinnerVietQrUrl({
  required AuctionPaymentConfigModel paymentConfig,
  required num amount,
  required String transferContent,
}) {
  final templateUrl = paymentConfig.qrImageUrl.trim();
  final amountText = amount.round().toString();
  final encodedContent = Uri.encodeQueryComponent(transferContent);
  final accountName =
      Uri.encodeQueryComponent(paymentConfig.accountHolderName.trim());

  if (templateUrl.contains('{amount}') ||
      templateUrl.contains('{addInfo}') ||
      templateUrl.contains('{accountName}') ||
      templateUrl.contains('{content}')) {
    return templateUrl
        .replaceAll('{amount}', amountText)
        .replaceAll('{addInfo}', encodedContent)
        .replaceAll('{content}', encodedContent)
        .replaceAll('{accountName}', accountName);
  }

  final bankCode = _resolveVietQrBankCode(paymentConfig.bankName);
  final accountNumber = paymentConfig.accountNumber.trim();
  if (bankCode.isEmpty || accountNumber.isEmpty) {
    return templateUrl;
  }

  return 'https://img.vietqr.io/image/$bankCode-$accountNumber-compact2.png'
      '?amount=$amountText'
      '&addInfo=$encodedContent'
      '&accountName=$accountName';
}

String _resolveVietQrBankCode(String bankName) {
  final normalized = bankName
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]'), '');

  const aliases = {
    'MB': 'MB',
    'MBBANK': 'MB',
    'MILITARYBANK': 'MB',
    'VIETCOMBANK': 'VCB',
    'VCB': 'VCB',
    'TECHCOMBANK': 'TCB',
    'TCB': 'TCB',
    'BIDV': 'BIDV',
    'VIETINBANK': 'ICB',
    'ICB': 'ICB',
    'AGRIBANK': 'VBA',
    'ACB': 'ACB',
    'SACOMBANK': 'STB',
    'STB': 'STB',
    'VPBANK': 'VPB',
    'VPB': 'VPB',
    'TPBANK': 'TPB',
    'TPB': 'TPB',
  };

  return aliases[normalized] ?? normalized;
}
