import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../data/models/winner_ranking_model.dart';
import '../../data/services/admin_winner_service.dart';
import '../../domain/entities/winner_entity.dart';
import '../widgets/winner_detail_address_card.dart';
import '../widgets/winner_detail_product_card.dart';
import '../widgets/winner_detail_status_timeline.dart';
import '../widgets/winner_detail_user_info.dart';
import '../widgets/winner_receipt_preview.dart';

class AdminWinnerDetailPage extends StatefulWidget {
  final WinnerEntity winner;

  const AdminWinnerDetailPage({super.key, required this.winner});

  @override
  State<AdminWinnerDetailPage> createState() => _AdminWinnerDetailPageState();
}

class _AdminWinnerDetailPageState extends State<AdminWinnerDetailPage> {
  final AdminWinnerService _winnerService = AdminWinnerService();
  bool _loadingRanking = true;
  bool _busy = false;
  String? _error;
  List<WinnerRankingModel> _ranking = const [];
  final Set<String> _viewedReceipts = {};

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _loadingRanking = false;
        _error = 'Ban can dang nhap admin';
      });
      return;
    }

    setState(() {
      _loadingRanking = true;
      _error = null;
    });

    try {
      final ranking = await _winnerService.getWinnerRanking(
        accessToken: accessToken,
        roomId: widget.winner.id,
      );
      if (!mounted) return;
      setState(() {
        _ranking = ranking;
        _loadingRanking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingRanking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            WinnerDetailUserInfo(winner: widget.winner),
            const SizedBox(height: 16),
            const WinnerDetailAddressCard(),
            const SizedBox(height: 16),
            WinnerDetailProductCard(winner: widget.winner),
            const SizedBox(height: 16),
            _buildRankingManager(),
            const SizedBox(height: 16),
            const WinnerDetailStatusTimeline(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Chi tiet nguoi thang',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${widget.winner.id}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingManager() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xep hang dau gia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tai lai',
                onPressed: _busy ? null : _loadRanking,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Admin hoi toi hang 5 thi dung. Hang nao khong nhan co the danh dau mat coc, sau do hoi hang tiep theo.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.35),
          ),
          const SizedBox(height: 16),
          if (_loadingRanking)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _buildError()
          else if (_ranking.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Phong nay chua co du lieu xep hang.'),
            )
          else ...[
            ..._ranking.map(_buildRankingTile),
          ],
        ],
      ),
    );
  }

  Widget _buildRankingTile(WinnerRankingModel item) {
    final isFirst = item.rank == 1;
    final canAsk =
        item.rank > 1 &&
        item.activeOffer &&
        (item.winnerPaymentStatus == 'WAITING_PAYMENT' ||
            item.winnerPaymentStatus == 'WAITING_ACCEPTANCE' ||
            item.winnerPaymentStatus == 'PAYMENT_REJECTED');
    final canForfeit =
        item.activeOffer &&
        item.depositStatus != 'FORFEITED' &&
        item.depositStatus != 'REFUNDED' &&
        item.depositStatus != 'SETTLED';
    final canRefund = item.rank >= 2 && item.rank <= 5;
    final canReviewPayment =
        item.activeOffer && item.winnerPaymentStatus == 'PAYMENT_SUBMITTED';
    final hasViewedReceipt = _hasViewedReceipt(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFirst ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.primaryBlue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '#${item.rank}',
                  style: TextStyle(
                    color: isFirst ? Colors.white : const Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName.isEmpty ? item.userEmail : item.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      item.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (item.activeOffer && item.winnerPaymentStatus != null) ...[
            _buildPaymentStatusBox(item),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildChip(_formatMoney(item.amount), const Color(0xFFDCFCE7)),
              _buildChip(
                _depositLabel(item.depositStatus),
                const Color(0xFFF1F5F9),
              ),
              if (canAsk)
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : () => _sendOffer(item.rank),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Gui hoi'),
                ),
              if (canForfeit)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _forfeitRank(item.rank),
                  icon: const Icon(Icons.block),
                  label: const Text('Mat coc'),
                ),
              if (canRefund)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _refundRank(item.rank),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Hoan coc'),
                ),
              if (canReviewPayment)
                FilledButton.icon(
                  onPressed: _busy || !hasViewedReceipt
                      ? null
                      : () => _confirmWinnerPayment(),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(
                    hasViewedReceipt ? 'Duyet thanh toan' : 'Can xem bien lai',
                  ),
                ),
              if (canReviewPayment)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _rejectWinnerPayment(),
                  icon: const Icon(Icons.close),
                  label: const Text('Tu choi'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBox(WinnerRankingModel item) {
    return Container(
      width: double.infinity,
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
            'Thanh toan: ${_paymentLabel(item.winnerPaymentStatus)}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          if ((item.winnerPaymentRejectedCount ?? 0) > 0) ...[
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
            Text(
              'Ghi chu user: ${item.winnerPaymentUserNote}',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ],
          if ((item.winnerPaymentAdminNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ghi chu admin: ${item.winnerPaymentAdminNote}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Text(
          _error ?? 'Khong the tai xep hang',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFDC2626)),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _loadRanking, child: const Text('Thu lai')),
      ],
    );
  }

  Future<void> _sendOffer(int rank) async {
    final sendEmail = await _askSendEmail('Gui hoi hang $rank');
    if (sendEmail == null) return;
    await _runAction(
      successMessage: 'Da gui hoi hang $rank',
      action: (token) => _winnerService.sendOffer(
        accessToken: token,
        roomId: widget.winner.id,
        rank: rank,
        sendEmail: sendEmail,
      ),
    );
  }

  Future<void> _forfeitRank(int rank) async {
    final sendEmail = await _askSendEmail('Danh dau mat coc hang $rank');
    if (sendEmail == null) return;
    await _runAction(
      successMessage: 'Da danh dau mat coc hang $rank',
      action: (token) => _winnerService.forfeitRank(
        accessToken: token,
        roomId: widget.winner.id,
        rank: rank,
        sendEmail: sendEmail,
      ),
    );
  }

  Future<void> _refundRank(int rank) async {
    await _runAction(
      successMessage: 'Da hoan coc hang $rank',
      action: (token) async {
        final ranking = await _winnerService.refundRank(
          accessToken: token,
          roomId: widget.winner.id,
          rank: rank,
        );
        if (!mounted) return;
        setState(() => _ranking = ranking);
      },
    );
  }

  Future<void> _confirmWinnerPayment() async {
    await _runAction(
      successMessage: 'Da duyet thanh toan va tat toan coc nguoi thang',
      action: (token) async {
        final ranking = await _winnerService.confirmWinnerPayment(
          accessToken: token,
          roomId: widget.winner.id,
          adminNote: 'Admin da doi soat bank va xac nhan thanh toan',
        );
        if (!mounted) return;
        setState(() => _ranking = ranking);
      },
    );
  }

  Future<void> _rejectWinnerPayment() async {
    await _runAction(
      successMessage: 'Da tu choi bien lai',
      action: (token) async {
        final ranking = await _winnerService.rejectWinnerPayment(
          accessToken: token,
          roomId: widget.winner.id,
          adminNote: 'Bien lai chua hop le hoac chua thay tien vao bank',
        );
        if (!mounted) return;
        setState(() => _ranking = ranking);
      },
    );
  }

  Future<void> _runAction({
    required String successMessage,
    required Future<void> Function(String token) action,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showSnack('Ban can dang nhap admin', isError: true);
      return;
    }

    setState(() => _busy = true);
    try {
      await action(accessToken);
      await _loadRanking();
      _showSnack(successMessage);
    } catch (error) {
      _showSnack(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : null,
      ),
    );
  }

  String _receiptKey(WinnerRankingModel item) {
    return '${widget.winner.id}:${item.rank}:${item.winnerPaymentReceiptUrl ?? ''}';
  }

  bool _hasViewedReceipt(WinnerRankingModel item) {
    return _viewedReceipts.contains(_receiptKey(item));
  }

  void _markReceiptViewed(WinnerRankingModel item) {
    if (!mounted) return;
    setState(() => _viewedReceipts.add(_receiptKey(item)));
  }

  String _formatMoney(num amount) {
    final raw = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} VND';
  }

  String _depositLabel(String? status) {
    switch (status) {
      case 'APPROVED':
        return 'Coc da duyet';
      case 'REFUNDED':
        return 'Da hoan coc';
      case 'FORFEITED':
        return 'Mat coc';
      case 'SETTLED':
        return 'Da tat toan';
      case 'PENDING_APPROVAL':
        return 'Cho duyet coc';
      case 'PENDING_PAYMENT':
        return 'Cho chuyen coc';
      case 'REJECTED':
        return 'Coc bi tu choi';
      default:
        return 'Chua co coc';
    }
  }

  String _paymentLabel(String? status) {
    switch (status) {
      case 'WAITING_PAYMENT':
        return 'Cho user thanh toan';
      case 'WAITING_ACCEPTANCE':
        return 'Cho user dong y nhan san pham';
      case 'PAYMENT_SUBMITTED':
        return 'User da gui bien lai';
      case 'PAYMENT_REJECTED':
        return 'Da tu choi bien lai';
      case 'PAID':
        return 'Da xac nhan';
      default:
        return 'Dang xu ly';
    }
  }
}
