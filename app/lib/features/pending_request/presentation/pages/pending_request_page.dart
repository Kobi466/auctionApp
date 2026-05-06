import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auction/data/auction_participation_service.dart';
import '../../../auction/data/models/auction_deposit_model.dart';
import '../../../auction/data/models/auction_room_access_model.dart';
import '../../../auction/presentation/pages/join_auction_room_page.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../widgets/pending_request_card.dart';

class PendingRequestPage extends StatefulWidget {
  const PendingRequestPage({super.key});

  @override
  State<PendingRequestPage> createState() => _PendingRequestPageState();
}

class _PendingRequestPageState extends State<PendingRequestPage> {
  final AuctionParticipationService _service = AuctionParticipationService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<AuctionDepositModel> _deposits = const [];
  Map<String, AuctionRoomAccessModel> _roomAccessByProductId = const {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadDeposits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeposits() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem yêu cầu chờ duyệt';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deposits = await _service.getMyDeposits(accessToken: accessToken);
      final roomAccessByProductId = await _loadApprovedRoomAccess(
        accessToken: accessToken,
        deposits: deposits,
      );
      if (!mounted) return;
      setState(() {
        _deposits = deposits;
        _roomAccessByProductId = roomAccessByProductId;
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

  Future<Map<String, AuctionRoomAccessModel>> _loadApprovedRoomAccess({
    required String accessToken,
    required List<AuctionDepositModel> deposits,
  }) async {
    final result = <String, AuctionRoomAccessModel>{};
    final approvedDeposits =
        deposits.where((deposit) => deposit.status == 'APPROVED');

    for (final deposit in approvedDeposits) {
      try {
        result[deposit.productId] = await _service.getRoomAccess(
          accessToken: accessToken,
          productId: deposit.productId,
        );
      } catch (_) {
        // Keep the approved request visible even if room credentials load later.
      }
    }

    return result;
  }

  List<String> get _categories {
    final pendingCount =
        _deposits.where((item) => item.status == 'PENDING_APPROVAL').length;
    final approvedCount =
        _deposits.where((item) => item.status == 'APPROVED').length;
    return [
      'Tất cả (${_deposits.length})',
      'Chờ duyệt ($pendingCount)',
      'Đã duyệt ($approvedCount)',
    ];
  }

  List<AuctionDepositModel> get _filteredDeposits {
    final keyword = _searchController.text.trim().toLowerCase();
    return _deposits.where((deposit) {
      var matchesTab = true;
      if (_selectedCategoryIndex == 1) {
        matchesTab = deposit.status == 'PENDING_APPROVAL';
      } else if (_selectedCategoryIndex == 2) {
        matchesTab = deposit.status == 'APPROVED';
      }

      final searchable = [
        deposit.productName,
        deposit.productId,
        deposit.transferContent,
        deposit.status,
      ].join(' ').toLowerCase();
      return matchesTab && (keyword.isEmpty || searchable.contains(keyword));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategories(),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 2),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm yêu cầu...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline_rounded,
        title: 'Không tải được yêu cầu',
        message: _errorMessage!,
        actionLabel: 'Thử lại',
        onAction: _loadDeposits,
      );
    }

    final deposits = _filteredDeposits;
    if (deposits.isEmpty) {
      return _MessageState(
        icon: Icons.assignment_outlined,
        title: 'Chưa có yêu cầu',
        message:
            'Yêu cầu đã chuyển khoản sẽ hiển thị tại đây để chờ admin duyệt.',
        actionLabel: 'Tải lại',
        onAction: _loadDeposits,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeposits,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: deposits.length + 1,
        itemBuilder: (context, index) {
          if (index == deposits.length) {
            return const SizedBox(height: 24);
          }
          final deposit = deposits[index];
          final roomAccess = _roomAccessByProductId[deposit.productId];
          return PendingRequestCard(
            title: _productTitle(deposit),
            time: _formatDate(deposit.paymentSubmittedAt ?? deposit.createdAt),
            amount: _formatCurrency(deposit.requiredAmount),
            status: deposit.status,
            transferContent: deposit.transferContent,
            adminNote: deposit.adminNote,
            roomCode: roomAccess?.roomCode,
            roomPassword: roomAccess?.roomPassword,
            onJoinRoom:
                roomAccess == null ? null : () => _openBidRoom(roomAccess),
          );
        },
      ),
    );
  }

  String _productTitle(AuctionDepositModel deposit) {
    final productName = deposit.productName.trim();
    if (productName.isNotEmpty) return productName;
    return 'Sản phẩm ${_shortId(deposit.productId)}';
  }

  void _openBidRoom(AuctionRoomAccessModel roomAccess) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JoinAuctionRoomPage(
          initialRoomCode: roomAccess.roomCode,
          initialPassword: roomAccess.roomPassword,
        ),
      ),
    );
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8).toUpperCase();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa cập nhật';
    final local = value.toLocal();
    return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}, '
        '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
  }

  String _formatCurrency(num value) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$buffer đ';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
