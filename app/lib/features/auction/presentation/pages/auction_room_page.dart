import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../data/auction_room_service.dart';
import '../../data/auction_stomp_service.dart';
import '../../data/models/auction_participant_model.dart';
import '../../data/models/auction_room_summary_model.dart';
import '../../data/models/bid_model.dart';
import '../../../admin/winner_management/presentation/widgets/winner_receipt_preview.dart';
import '../widgets/auction_price_card.dart';
import '../widgets/auction_product_header.dart';
import '../widgets/auction_stats_card.dart';
import '../widgets/bid_history_item.dart';
import 'bid_history_page.dart';

class AuctionRoomPage extends StatefulWidget {
  final String roomId;

  const AuctionRoomPage({super.key, required this.roomId});

  @override
  State<AuctionRoomPage> createState() => _AuctionRoomPageState();
}

class _AuctionRoomPageState extends State<AuctionRoomPage> {
  static const num _defaultBidIncrement = 500000;

  final AuctionRoomService _service = AuctionRoomService();
  final AuctionStompService _stompService = AuctionStompService();
  final TextEditingController _bidController = TextEditingController();
  final TextEditingController _winnerReceiptController =
      TextEditingController();
  final TextEditingController _winnerNoteController = TextEditingController();
  final ValueNotifier<DateTime> _nowNotifier = ValueNotifier(DateTime.now());
  Timer? _bidCooldownTimer;
  Timer? _roomClockTimer;

  bool _isLoading = true;
  bool _isSubmittingBid = false;
  bool _isSubmittingWinnerPayment = false;
  bool _isAcceptingWinnerOffer = false;
  bool _isRealtimeConnected = false;
  int _bidCooldownSeconds = 0;
  String? _errorMessage;
  AuctionRoomSummaryModel? _summary;

  @override
  void initState() {
    super.initState();
    _startRoomClock();
    _loadRoom();
  }

  @override
  void dispose() {
    _bidCooldownTimer?.cancel();
    _roomClockTimer?.cancel();
    _stompService.disconnect();
    _nowNotifier.dispose();
    _bidController.dispose();
    _winnerReceiptController.dispose();
    _winnerNoteController.dispose();
    super.dispose();
  }

  void _startRoomClock() {
    _roomClockTimer?.cancel();
    _roomClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _nowNotifier.value = DateTime.now();
    });
  }

  Future<void> _loadRoom() async {
    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty || widget.roomId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Khong tim thay thong tin phong dau gia';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _service.getRoomSummary(
        accessToken: accessToken,
        roomId: widget.roomId,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _bidController.text = formatMoneyInput(_defaultBidIncrement);
        _isLoading = false;
      });
      _connectRealtime(accessToken);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _placeBid() async {
    final accessToken = AuthSession.instance.accessToken ?? '';
    final availabilityMessage = _bidAvailabilityMessage(
      _summary,
      _nowNotifier.value,
    );
    if (availabilityMessage != null) {
      _showError(availabilityMessage);
      return;
    }

    final amount = num.tryParse(
      _bidController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (accessToken.isEmpty || amount == null || amount <= 0) {
      _showError('Nhap gia dau hop le');
      return;
    }

    setState(() => _isSubmittingBid = true);
    try {
      if (_stompService.isConnected) {
        _stompService.sendBid(roomId: widget.roomId, amount: amount);
        _startBidCooldown();
      } else {
        await _service.placeBid(
          accessToken: accessToken,
          roomId: widget.roomId,
          amount: amount,
        );
        _startBidCooldown();
        await _loadRoom();
      }
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmittingBid = false);
    }
  }

  Future<void> _submitWinnerPayment() async {
    final accessToken = AuthSession.instance.accessToken ?? '';
    final receipt = _winnerReceiptController.text.trim();
    final note = _winnerNoteController.text.trim();
    if (accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }
    if (receipt.isEmpty && note.isEmpty) {
      _showError('Nhap link bien lai hoac ghi chu chuyen khoan');
      return;
    }

    setState(() => _isSubmittingWinnerPayment = true);
    try {
      final summary = await _service.submitWinnerPayment(
        accessToken: accessToken,
        roomId: widget.roomId,
        receiptUrl: receipt.isEmpty ? null : receipt,
        userNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _winnerReceiptController.clear();
        _winnerNoteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui bien lai cho admin kiem tra')),
      );
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmittingWinnerPayment = false);
    }
  }

  Future<void> _acceptWinnerOffer() async {
    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    setState(() => _isAcceptingWinnerOffer = true);
    try {
      final summary = await _service.acceptWinnerOffer(
        accessToken: accessToken,
        roomId: widget.roomId,
      );
      if (!mounted) return;
      setState(() => _summary = summary);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da dong y nhan san pham')));
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isAcceptingWinnerOffer = false);
    }
  }

  void _startBidCooldown() {
    _bidCooldownTimer?.cancel();
    if (!mounted) return;
    setState(() => _bidCooldownSeconds = 5);

    _bidCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_bidCooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _bidCooldownSeconds = 0);
        return;
      }

      setState(() => _bidCooldownSeconds--);
    });
  }

  void _connectRealtime(String accessToken) {
    setState(() => _isRealtimeConnected = false);
    _stompService.connect(
      accessToken: accessToken,
      roomId: widget.roomId,
      onConnected: () {
        if (!mounted) return;
        setState(() => _isRealtimeConnected = true);
      },
      onBid: _handleRealtimeBid,
      onAuctionUpdate: _handleAuctionUpdate,
      onNotification: _handleRealtimeNotification,
      onError: (message) {
        if (!mounted) return;
        _showError(message);
      },
    );
  }

  void _handleRealtimeBid(BidModel bid) {
    final summary = _summary;
    if (!mounted || summary == null) return;

    final updatedBids = [
      bid,
      ...summary.bids
          .where((item) {
            return item.userId != bid.userId ||
                item.amount != bid.amount ||
                item.createdAt != bid.createdAt;
          })
          .map((item) {
            return BidModel(
              id: item.id,
              userId: item.userId,
              userName: item.userName,
              userAvatar: item.userAvatar,
              amount: item.amount,
              createdAt: item.createdAt,
            );
          }),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final currentPrice = bid.amount > summary.currentPrice
        ? bid.amount
        : summary.currentPrice;

    setState(() {
      _summary = AuctionRoomSummaryModel(
        product: summary.product,
        currentPrice: currentPrice,
        bidCount: summary.bidCount + 1,
        watcherCount: summary.watcherCount,
        participants: summary.participants,
        bids: updatedBids,
      );
      _bidController.text = formatMoneyInput(_defaultBidIncrement);
    });
  }

  void _handleAuctionUpdate(AuctionUpdateModel update) {
    final summary = _summary;
    if (!mounted || summary == null) return;

    final currentRoom = summary.product.auctionRoom;
    final updatedProduct = update.endTime == null || currentRoom == null
        ? summary.product
        : summary.product.copyWith(
            auctionRoom: currentRoom.copyWith(endTime: update.endTime),
          );

    setState(() {
      _summary = AuctionRoomSummaryModel(
        product: updatedProduct,
        currentPrice: update.currentPrice,
        bidCount: summary.bidCount,
        watcherCount: summary.watcherCount,
        participants: summary.participants,
        bids: summary.bids,
      );
    });
  }

  void _handleRealtimeNotification(AuctionNotificationModel notification) {
    if (!mounted) return;
    final message = notification.type == 'OUTBID'
        ? 'Da co nguoi dat gia cao hon ban'
        : notification.message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primaryBlue),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(_errorMessage!)
          : summary == null
          ? _buildErrorState('Khong co du lieu phong')
          : RefreshIndicator(
              onRefresh: _loadRoom,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    AuctionProductHeader(product: summary.product),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _nowNotifier,
                      builder: (context, now, _) => AuctionPriceCard(
                        startingPrice: summary.product.startingPrice,
                        currentPrice: summary.currentPrice,
                        endTime: _formatTimeLeft(
                          summary.product.auctionRoom?.endTime,
                          now,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuctionStatsCard(
                      bidCount: summary.bidCount,
                      watcherCount: summary.watcherCount,
                    ),
                    const SizedBox(height: 16),
                    _buildParticipantsSection(summary.participants),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _nowNotifier,
                      builder: (context, now, _) =>
                          _buildBiddingSection(summary, now),
                    ),
                    const SizedBox(height: 16),
                    _buildWinnerPaymentSection(summary),
                    const SizedBox(height: 24),
                    _buildHistorySection(summary.bids),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          const Text(
            'Phong dau gia',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _isRealtimeConnected ? 'TRUC TIEP' : 'DANG NOI',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
          onPressed: _loadRoom,
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRoom, child: const Text('Tai lai')),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(List<AuctionParticipantModel> participants) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nguoi da dang ky dau gia',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            if (participants.isEmpty)
              const Text(
                'Chua co nguoi dang ky',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              )
            else
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: participants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          participant.userName.isEmpty
                              ? '?'
                              : participant.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(participant.userName),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiddingSection(AuctionRoomSummaryModel summary, DateTime now) {
    final leadingName = summary.bids.isEmpty
        ? 'Chua co'
        : summary.bids.first.userName;
    final availabilityMessage = _bidAvailabilityMessage(summary, now);
    final isBidDisabled =
        _isSubmittingBid ||
        availabilityMessage != null ||
        _bidCooldownSeconds > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dan dau: $leadingName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text(
                'NHAP TIEN CONG THEM',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: TextField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nhap tien cong',
                      suffixText: 'VNĐ',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isBidDisabled ? null : _placeBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isSubmittingBid
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _bidCooldownSeconds > 0
                            ? '${_bidCooldownSeconds}s'
                            : 'DAT GIA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          if (availabilityMessage != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                availabilityMessage,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWinnerPaymentSection(AuctionRoomSummaryModel summary) {
    final status = summary.winnerPaymentStatus;
    final canAccept = status == 'WAITING_ACCEPTANCE';
    final canSubmit =
        status == 'WAITING_PAYMENT' || status == 'PAYMENT_REJECTED';
    if (!summary.currentUserWinnerPaymentEligible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thanh toan dau gia hang ${summary.currentWinnerRank ?? '-'}',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'So tien can thanh toan: ${formatVnd(summary.winnerPaymentAmount)}',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _winnerPaymentStatusText(
                status,
                summary.winnerPaymentRejectedCount,
              ),
              style: const TextStyle(color: Color(0xFF64748B), height: 1.35),
            ),
            if ((summary.winnerPaymentReceiptUrl ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              WinnerReceiptPreview(
                receiptPath: summary.winnerPaymentReceiptUrl ?? '',
              ),
            ],
            if (canAccept) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAcceptingWinnerOffer
                      ? null
                      : _acceptWinnerOffer,
                  icon: _isAcceptingWinnerOffer
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Dong y nhan san pham'),
                ),
              ),
            ],
            if (canSubmit) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _winnerReceiptController,
                decoration: const InputDecoration(
                  labelText: 'Link bien lai / ma giao dich',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _winnerNoteController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chu chuyen khoan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmittingWinnerPayment
                      ? null
                      : _submitWinnerPayment,
                  icon: _isSubmittingWinnerPayment
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.receipt_long_outlined),
                  label: const Text('Gui bien lai cho admin'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(List<BidModel> bids) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lich su dau gia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: bids.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BidHistoryPage(bids: bids),
                          ),
                        );
                      },
                child: const Text(
                  'XEM TAT CA',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (bids.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Chua co luot dau nao',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            )
          else
            ...bids.take(3).map((bid) => BidHistoryItem(bid: bid)),
        ],
      ),
    );
  }

  String _formatTimeLeft(DateTime? endTime, DateTime now) {
    if (endTime == null) return '--:--:--';
    final diff = endTime.difference(now);
    if (diff.isNegative) return '00:00:00';
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String? _bidAvailabilityMessage(
    AuctionRoomSummaryModel? summary,
    DateTime now,
  ) {
    final room = summary?.product.auctionRoom;
    final startTime = room?.startTime;
    final endTime = room?.endTime;

    if (startTime != null && now.isBefore(startTime)) {
      return 'Phiên đấu giá bắt đầu lúc ${_formatDateTime(startTime)}';
    }
    if (endTime != null && !now.isBefore(endTime)) {
      return 'Phiên đấu giá đã kết thúc';
    }
    return null;
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month ${hour}h$minute';
  }

  String _winnerPaymentStatusText(String? status, int? rejectedCount) {
    switch (status) {
      case 'WAITING_ACCEPTANCE':
        return 'Nguoi xep hang truoc da bi loai. Neu dong y nhan san pham, ban hay xac nhan truoc khi thanh toan.';
      case 'WAITING_PAYMENT':
        return 'Ban dang duoc yeu cau thanh toan vao tai khoan bank admin, sau do gui bien lai tai day.';
      case 'PAYMENT_SUBMITTED':
        return 'Bien lai da gui, vui long doi admin doi soat bank va xac nhan.';
      case 'PAYMENT_REJECTED':
        return 'Bien lai chua duoc xac nhan. Hay kiem tra giao dich va gui lai. Lan tu choi ${rejectedCount ?? 0}/3.';
      default:
        return 'Vui long lam theo thong bao cua admin.';
    }
  }
}
