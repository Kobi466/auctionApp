import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../auction/data/auction_room_service.dart';
import '../../../../auction/data/models/auction_room_summary_model.dart';
import '../../../../auction/presentation/pages/bid_history_page.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../winner_management/data/models/winner_ranking_model.dart';
import '../../../winner_management/data/services/admin_winner_service.dart';
import '../../../winner_management/presentation/widgets/winner_receipt_preview.dart';
import '../../data/admin_auction_service.dart';
import '../widgets/auction_detail_actions.dart';
import '../widgets/auction_detail_description.dart';
import '../widgets/auction_detail_history.dart';
import '../widgets/auction_detail_image.dart';
import '../widgets/auction_detail_info.dart';
import '../widgets/auction_detail_stats.dart';

class AdminAuctionDetailPage extends StatefulWidget {
  final ProductModel product;

  const AdminAuctionDetailPage({super.key, required this.product});

  @override
  State<AdminAuctionDetailPage> createState() => _AdminAuctionDetailPageState();
}

class _AdminAuctionDetailPageState extends State<AdminAuctionDetailPage> {
  final AdminAuctionService _auctionService = AdminAuctionService();
  final AuctionRoomService _roomService = AuctionRoomService();
  final AdminWinnerService _winnerService = AdminWinnerService();
  bool _isCancelling = false;
  bool _isLoadingCashFlow = false;
  bool _isCashFlowBusy = false;
  String? _cashFlowError;
  AuctionRoomSummaryModel? _roomSummary;
  List<WinnerRankingModel> _cashFlowRanking = const [];
  final Set<String> _viewedReceipts = {};

  @override
  void initState() {
    super.initState();
    _loadCashFlow();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final room = product.auctionRoom;
    final status = room?.status.toUpperCase() ?? '';
    final canCancel =
        room != null && (status == 'LIVE' || status == 'SCHEDULED');

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
                    category: product.brand.isEmpty
                        ? product.categoryId
                        : product.brand,
                    productId: _shortId(product.id),
                    title: product.name,
                    currentPrice: formatVnd(room?.minimumBid),
                    timeRemaining: _roomTimeLabel(status, room?.endTime),
                  ),
                  const SizedBox(height: 32),
                  AuctionDetailStats(
                    bidCount: _roomSummary?.bidCount ?? 0,
                    viewCount: (_roomSummary?.watcherCount ?? 0).toString(),
                    participantCount: _roomSummary?.participants.length ?? 0,
                  ),
                  const SizedBox(height: 32),
                  _buildCashFlowManager(),
                  const SizedBox(height: 32),
                  AuctionDetailHistory(
                    bids: _roomSummary?.bids ?? const [],
                    isLoading: _isLoadingCashFlow,
                    errorMessage: _cashFlowError,
                    onRetry: _loadCashFlow,
                    onViewAll: _openBidHistory,
                  ),
                  const SizedBox(height: 32),
                  AuctionDetailDescription(description: _description(product)),
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

  Future<void> _loadCashFlow() async {
    final roomId = widget.product.auctionRoom?.id;
    if (roomId == null || roomId.isEmpty) return;

    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() => _cashFlowError = 'Khong tim thay access token');
      return;
    }

    setState(() {
      _isLoadingCashFlow = true;
      _cashFlowError = null;
    });

    try {
      final results = await Future.wait([
        _roomService.getRoomSummary(accessToken: accessToken, roomId: roomId),
        _winnerService.getWinnerRanking(
          accessToken: accessToken,
          roomId: roomId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _roomSummary = results[0] as AuctionRoomSummaryModel;
        _cashFlowRanking = results[1] as List<WinnerRankingModel>;
        _isLoadingCashFlow = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cashFlowError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingCashFlow = false;
      });
    }
  }

  Widget _buildCashFlowManager() {
    final room = widget.product.auctionRoom;
    if (room == null) {
      return _sectionCard(
        child: const Text('Phong dau gia chua duoc tao nen chua co dong tien.'),
      );
    }

    final winningBid = _cashFlowRanking.isEmpty ? null : _cashFlowRanking.first;
    final depositAmount = room.depositAmount;
    final approvedDepositCountFromRanking = _cashFlowRanking
        .where((item) => item.depositStatus == 'APPROVED')
        .length;
    final approvedDepositCount =
        _roomSummary?.participants.length ?? approvedDepositCountFromRanking;
    final collectedDeposit = approvedDepositCount * depositAmount;
    final forfeitedDeposit =
        _cashFlowRanking
            .where((item) => item.depositStatus == 'FORFEITED')
            .length *
        depositAmount;
    final refundedDeposit =
        _cashFlowRanking
            .where((item) => item.depositStatus == 'REFUNDED')
            .length *
        depositAmount;
    final settledDeposit =
        _cashFlowRanking
            .where((item) => item.depositStatus == 'SETTLED')
            .length *
        depositAmount;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quan ly dong tien dau gia',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tai lai dong tien',
                onPressed: _isCashFlowBusy ? null : _loadCashFlow,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_canManageWinnerFlow && _cashFlowRanking.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCashFlowBusy ? null : _refundLosingDeposits,
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Hoan coc tat ca'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _moneyBox('Gia thang', formatVnd(winningBid?.amount)),
              _moneyBox('Coc dang giu', formatVnd(collectedDeposit)),
              _moneyBox('Coc mat', formatVnd(forfeitedDeposit)),
              _moneyBox('Coc da hoan', formatVnd(refundedDeposit)),
              _moneyBox('Coc tat toan', formatVnd(settledDeposit)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingCashFlow)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_cashFlowError != null)
            _cashFlowErrorView()
          else if (_cashFlowRanking.isEmpty)
            const Text('Chua co nguoi dat gia trong phong nay.')
          else ...[
            if (!_canManageWinnerFlow)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Phong chua ket thuc nen chua the hoi nguoi tiep theo, mat coc hoac hoan coc.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.35),
                ),
              ),
            ..._cashFlowRanking.map(_cashFlowRankTile),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _moneyBox(String label, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashFlowRankTile(WinnerRankingModel item) {
    final canAsk =
        _canManageWinnerFlow &&
        item.rank > 1 &&
        item.activeOffer &&
        (item.winnerPaymentStatus == 'WAITING_PAYMENT' ||
            item.winnerPaymentStatus == 'WAITING_ACCEPTANCE' ||
            item.winnerPaymentStatus == 'PAYMENT_REJECTED');
    final canForfeit =
        _canManageWinnerFlow &&
        item.activeOffer &&
        item.depositStatus != 'FORFEITED' &&
        item.depositStatus != 'REFUNDED' &&
        item.depositStatus != 'SETTLED';
    final canConfirmPayment =
        item.activeOffer && item.winnerPaymentStatus == 'PAYMENT_SUBMITTED';
    final hasViewedReceipt = _hasViewedReceipt(item);
    final canRefund =
        _canManageWinnerFlow &&
        item.rank >= 2 &&
        item.rank <= 5 &&
        item.depositStatus != 'REFUNDED' &&
        item.depositStatus != 'FORFEITED' &&
        item.depositStatus != 'SETTLED';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.rank == 1
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: item.rank == 1
                    ? const Color(0xFF2563EB)
                    : Colors.white,
                child: Text(
                  '#${item.rank}',
                  style: TextStyle(
                    color: item.rank == 1
                        ? Colors.white
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName.isEmpty ? item.userEmail : item.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${formatVnd(item.amount)} - ${_depositLabel(item.depositStatus)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.activeOffer) ...[
            const SizedBox(height: 10),
            _paymentStatusBox(item),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canAsk)
                FilledButton.tonalIcon(
                  onPressed: _isCashFlowBusy
                      ? null
                      : () => _sendOffer(item.rank),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Hoi qua Gmail'),
                ),
              if (canForfeit)
                OutlinedButton.icon(
                  onPressed: _isCashFlowBusy
                      ? null
                      : () => _forfeitRank(item.rank),
                  icon: const Icon(Icons.block),
                  label: const Text('Mat coc'),
                ),
              if (canConfirmPayment)
                FilledButton.icon(
                  onPressed: _isCashFlowBusy || !hasViewedReceipt
                      ? null
                      : () => _confirmWinnerPayment(item.rank),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(
                    hasViewedReceipt
                        ? 'Xac nhan da nhan tien'
                        : 'Can xem bien lai',
                  ),
                ),
              if (canConfirmPayment)
                OutlinedButton.icon(
                  onPressed: _isCashFlowBusy
                      ? null
                      : () => _rejectWinnerPayment(item.rank),
                  icon: const Icon(Icons.report_gmailerrorred_outlined),
                  label: const Text('Tu choi bien lai'),
                ),
              if (canRefund)
                OutlinedButton.icon(
                  onPressed: _isCashFlowBusy
                      ? null
                      : () => _refundRank(item.rank),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Hoan coc'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentStatusBox(WinnerRankingModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thanh toan: ${_winnerPaymentLabel(item.winnerPaymentStatus)}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          if ((item.winnerPaymentRejectedCount ?? 0) > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Da tu choi ${item.winnerPaymentRejectedCount}/3 lan. Duoi 3 lan user van co the gui lai.',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
          if ((item.winnerPaymentReceiptUrl ?? '').isNotEmpty) ...[
            WinnerReceiptPreview(
              receiptPath: item.winnerPaymentReceiptUrl ?? '',
              onOpened: () => _markReceiptViewed(item),
            ),
          ],
          if ((item.winnerPaymentUserNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Ghi chu user: ${item.winnerPaymentUserNote}',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ],
          if ((item.winnerPaymentAdminNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Ghi chu admin: ${item.winnerPaymentAdminNote}',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cashFlowErrorView() {
    return Column(
      children: [
        Text(
          _cashFlowError ?? 'Khong tai duoc dong tien',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFDC2626)),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _loadCashFlow, child: const Text('Thu lai')),
      ],
    );
  }

  Future<void> _sendOffer(int rank) async {
    await _runCashFlowAction(
      successMessage: 'Da gui Gmail hoi hang $rank',
      action: (token, roomId) => _winnerService.sendOffer(
        accessToken: token,
        roomId: roomId,
        rank: rank,
        sendEmail: true,
      ),
    );
  }

  Future<void> _forfeitRank(int rank) async {
    final sendEmail = await _askSendEmail('Danh dau mat coc hang $rank');
    if (sendEmail == null) return;
    await _runCashFlowAction(
      successMessage: 'Da danh dau mat coc hang $rank',
      action: (token, roomId) => _winnerService.forfeitRank(
        accessToken: token,
        roomId: roomId,
        rank: rank,
        sendEmail: sendEmail,
      ),
    );
  }

  Future<void> _refundRank(int rank) async {
    await _runCashFlowAction(
      successMessage: 'Da hoan coc hang $rank',
      action: (token, roomId) async {
        final ranking = await _winnerService.refundRank(
          accessToken: token,
          roomId: roomId,
          rank: rank,
        );
        if (mounted) {
          setState(() => _cashFlowRanking = ranking);
        }
      },
    );
  }

  Future<void> _refundLosingDeposits() async {
    await _runCashFlowAction(
      successMessage: 'Da hoan coc tat ca nguoi khong thang',
      action: (token, roomId) async {
        final ranking = await _winnerService.refundLosingDeposits(
          accessToken: token,
          roomId: roomId,
        );
        if (mounted) {
          setState(() => _cashFlowRanking = ranking);
        }
      },
    );
  }

  Future<void> _confirmWinnerPayment(int rank) async {
    await _runCashFlowAction(
      successMessage: 'Da xac nhan thanh toan hang $rank',
      action: (token, roomId) async {
        final ranking = await _winnerService.confirmWinnerPayment(
          accessToken: token,
          roomId: roomId,
          adminNote: 'Admin da doi soat bank va xac nhan da nhan tien',
        );
        if (mounted) {
          setState(() => _cashFlowRanking = ranking);
        }
      },
    );
  }

  Future<void> _rejectWinnerPayment(int rank) async {
    await _runCashFlowAction(
      successMessage: 'Da tu choi bien lai hang $rank',
      action: (token, roomId) async {
        final ranking = await _winnerService.rejectWinnerPayment(
          accessToken: token,
          roomId: roomId,
          adminNote: 'Bien lai chua khop voi giao dich bank',
        );
        if (mounted) {
          setState(() => _cashFlowRanking = ranking);
        }
      },
    );
  }

  Future<void> _runCashFlowAction({
    required String successMessage,
    required Future<void> Function(String token, String roomId) action,
  }) async {
    final roomId = widget.product.auctionRoom?.id;
    final accessToken = AuthSession.instance.accessToken;
    if (roomId == null || roomId.isEmpty) {
      _showError('Phong dau gia khong hop le');
      return;
    }
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    setState(() => _isCashFlowBusy = true);
    try {
      await action(accessToken, roomId);
      await _loadCashFlow();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isCashFlowBusy = false);
      }
    }
  }

  Future<bool?> _askSendEmail(String title) {
    bool sendEmail = false;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Gui them email'),
                subtitle: const Text('Thong bao trong app luon duoc gui.'),
                value: sendEmail,
                onChanged: (value) => setDialogState(() => sendEmail = value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, sendEmail),
                  child: const Text('Xac nhan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openBidHistory() {
    final bids = _roomSummary?.bids ?? const [];
    if (bids.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BidHistoryPage(bids: bids)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da huy phien dau gia')));
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

  String _receiptKey(WinnerRankingModel item) {
    final roomId = widget.product.auctionRoom?.id ?? '';
    return '$roomId:${item.rank}:${item.winnerPaymentReceiptUrl ?? ''}';
  }

  bool _hasViewedReceipt(WinnerRankingModel item) {
    return _viewedReceipts.contains(_receiptKey(item));
  }

  void _markReceiptViewed(WinnerRankingModel item) {
    if (!mounted) return;
    setState(() => _viewedReceipts.add(_receiptKey(item)));
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
    if (status == 'WAITING_WINNER_PAYMENT') return 'Cho nguoi thang thanh toan';
    if (status == 'SOLD') return 'Da ban';
    if (status == 'FAILED') return 'Dau gia that bai';
    if (endTime == null) return status.isEmpty ? 'Chua co phong' : status;
    final local = endTime.toLocal();
    return '${_two(local.hour)}:${_two(local.minute)} - ${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8).toUpperCase();
  }

  bool get _isRoomClosed =>
      widget.product.auctionRoom?.status.toUpperCase() == 'CLOSED';

  bool get _canManageWinnerFlow =>
      _isRoomClosed ||
      widget.product.auctionRoom?.status.toUpperCase() ==
          'WAITING_WINNER_PAYMENT' ||
      _cashFlowRanking.any((item) => item.activeOffer);

  String _depositLabel(String? status) {
    switch (status) {
      case 'APPROVED':
        return 'coc da duyet';
      case 'REFUNDED':
        return 'da hoan coc';
      case 'FORFEITED':
        return 'mat coc';
      case 'SETTLED':
        return 'da tat toan';
      case 'PENDING_APPROVAL':
        return 'cho duyet coc';
      case 'PENDING_PAYMENT':
        return 'cho chuyen coc';
      case 'REJECTED':
        return 'coc bi tu choi';
      default:
        return 'chua co coc';
    }
  }

  String _winnerPaymentLabel(String? status) {
    switch (status) {
      case 'WAITING_PAYMENT':
        return 'cho user thanh toan';
      case 'WAITING_ACCEPTANCE':
        return 'cho user dong y nhan san pham';
      case 'PAYMENT_SUBMITTED':
        return 'user da gui bien lai';
      case 'PAID':
        return 'da xac nhan thanh toan';
      case 'PAYMENT_REJECTED':
        return 'bien lai bi tu choi';
      case 'FAILED':
        return 'phien that bai';
      default:
        return 'chua bat dau';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
