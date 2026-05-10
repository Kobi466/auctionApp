import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../home/data/models/product_model.dart';
import '../../data/admin_auction_service.dart';
import '../widgets/auction_detail_actions.dart';
import '../widgets/auction_detail_description.dart';
import '../widgets/auction_detail_history.dart';
import '../widgets/auction_detail_image.dart';
import '../widgets/auction_detail_info.dart';
import '../widgets/auction_detail_stats.dart';

class AdminAuctionDetailPage extends StatefulWidget {
  final ProductModel product;

  const AdminAuctionDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<AdminAuctionDetailPage> createState() => _AdminAuctionDetailPageState();
}

class _AdminAuctionDetailPageState extends State<AdminAuctionDetailPage> {
  final AdminAuctionService _auctionService = AdminAuctionService();
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final room = product.auctionRoom;
    final status = room?.status.toUpperCase() ?? '';
    final canCancel = room != null && (status == 'LIVE' || status == 'SCHEDULED');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiet dau gia',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AuctionDetailImage(
                    imageUrl: product.displayImage,
                    isLive: status == 'LIVE',
                  ),
                  const SizedBox(height: 24),
                  AuctionDetailInfo(
                    category: product.brand.isEmpty ? product.categoryId : product.brand,
                    productId: _shortId(product.id),
                    title: product.name,
                    currentPrice: formatVnd(room?.minimumBid),
                    timeRemaining: _roomTimeLabel(status, room?.endTime),
                  ),
                  const SizedBox(height: 32),
                  const AuctionDetailStats(
                    bidCount: 0,
                    viewCount: '0',
                    participantCount: 0,
                  ),
                  const SizedBox(height: 32),
                  const AuctionDetailHistory(),
                  const SizedBox(height: 32),
                  AuctionDetailDescription(
                    description: _description(product),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          AuctionDetailActions(
            canCancel: canCancel,
            isCancelling: _isCancelling,
            onCancel: canCancel ? _confirmCancel : null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final roomId = widget.product.auctionRoom?.id;
    if (roomId == null || roomId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Huy phien dau gia'),
        content: const Text(
          'Phien se chuyen sang trang thai da huy. Ban chac chan muon huy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Khong'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Huy phien'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _cancelAuction(roomId);
  }

  Future<void> _cancelAuction(String roomId) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    setState(() => _isCancelling = true);
    try {
      await _auctionService.cancelAuctionRoom(
        accessToken: accessToken,
        roomId: roomId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da huy phien dau gia')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _description(ProductModel product) {
    final description = product.description?.trim() ?? '';
    if (description.isNotEmpty) return description;
    final shortDescription = product.shortDescription?.trim() ?? '';
    if (shortDescription.isNotEmpty) return shortDescription;
    return 'Chua co mo ta san pham.';
  }

  String _roomTimeLabel(String status, DateTime? endTime) {
    if (status == 'CANCELLED') return 'Da huy';
    if (status == 'CLOSED') return 'Da ket thuc';
    if (endTime == null) return status.isEmpty ? 'Chua co phong' : status;
    final local = endTime.toLocal();
    return '${_two(local.hour)}:${_two(local.minute)} - ${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8).toUpperCase();
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
