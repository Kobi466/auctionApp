import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../data/auction_room_service.dart';
import '../../data/models/auction_participant_model.dart';
import '../../data/models/auction_room_summary_model.dart';
import '../../data/models/bid_model.dart';
import '../widgets/auction_price_card.dart';
import '../widgets/auction_product_header.dart';
import '../widgets/auction_stats_card.dart';
import '../widgets/bid_history_item.dart';
import 'bid_history_page.dart';

class AuctionRoomPage extends StatefulWidget {
  final String roomId;

  const AuctionRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<AuctionRoomPage> createState() => _AuctionRoomPageState();
}

class _AuctionRoomPageState extends State<AuctionRoomPage> {
  final AuctionRoomService _service = AuctionRoomService();
  final TextEditingController _bidController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmittingBid = false;
  String? _errorMessage;
  AuctionRoomSummaryModel? _summary;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
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
        _bidController.text = formatMoneyInput(summary.currentPrice + 10000000);
        _isLoading = false;
      });
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
    final amount = num.tryParse(
      _bidController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (accessToken.isEmpty || amount == null || amount <= 0) {
      _showError('Nhap gia dau hop le');
      return;
    }

    setState(() => _isSubmittingBid = true);
    try {
      await _service.placeBid(
        accessToken: accessToken,
        roomId: widget.roomId,
        amount: amount,
      );
      await _loadRoom();
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmittingBid = false);
    }
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
                            AuctionPriceCard(
                              startingPrice: summary.product.startingPrice,
                              currentPrice: summary.currentPrice,
                              endTime: _formatTimeLeft(
                                summary.product.auctionRoom?.endTime,
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
                            _buildBiddingSection(summary),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
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
              const Text(
                'TRUC TIEP',
                style: TextStyle(
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
            ElevatedButton(
              onPressed: _loadRoom,
              child: const Text('Tai lai'),
            ),
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
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
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

  Widget _buildBiddingSection(AuctionRoomSummaryModel summary) {
    final leadingName =
        summary.bids.isEmpty ? 'Chua co' : summary.bids.first.userName;
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
                'BUOC GIA: +10.000.000 VNĐ',
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
                      hintText: 'Nhap gia',
                      suffixText: 'VNĐ',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmittingBid ? null : _placeBid,
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
                    : const Text(
                        'DAT GIA',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ],
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

  String _formatTimeLeft(DateTime? endTime) {
    if (endTime == null) return '--:--';
    final diff = endTime.difference(DateTime.now());
    if (diff.isNegative) return '00:00';
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
