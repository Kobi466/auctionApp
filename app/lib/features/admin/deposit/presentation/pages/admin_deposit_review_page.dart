import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../withdrawal/presentation/pages/admin_withdrawal_review_page.dart';
import '../../data/models/admin_deposit_model.dart';
import '../../data/sources/admin_deposit_service.dart';

class AdminDepositReviewPage extends StatefulWidget {
  const AdminDepositReviewPage({super.key});

  @override
  State<AdminDepositReviewPage> createState() => _AdminDepositReviewPageState();
}

class _AdminDepositReviewPageState extends State<AdminDepositReviewPage> {
  final AdminDepositService _depositService = AdminDepositService(ApiClient());
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'PENDING_APPROVAL';
  String? _selectedRoomId;
  List<AdminDepositModel> _deposits = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
    _loadDeposits();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
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
        _errorMessage = 'Khong tim thay access token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deposits = await _depositService.getDeposits(
        accessToken: accessToken,
      );
      if (!mounted) return;
      setState(() {
        _deposits = deposits;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<AdminDepositModel> get _filteredDeposits {
    final keyword = _searchController.text.trim().toLowerCase();
    return _deposits.where((deposit) {
      final matchesRoom =
          _selectedRoomId == null || deposit.auctionRoomId == _selectedRoomId;
      final matchesStatus =
          _selectedStatus == 'ALL' || deposit.status == _selectedStatus;
      final matchesSearch =
          keyword.isEmpty ||
          deposit.id.toLowerCase().contains(keyword) ||
          deposit.auctionRoomId.toLowerCase().contains(keyword) ||
          deposit.userId.toLowerCase().contains(keyword) ||
          deposit.username.toLowerCase().contains(keyword) ||
          deposit.userEmail.toLowerCase().contains(keyword) ||
          deposit.userFullName.toLowerCase().contains(keyword) ||
          deposit.productId.toLowerCase().contains(keyword) ||
          deposit.productName.toLowerCase().contains(keyword) ||
          deposit.transferContent.toLowerCase().contains(keyword);
      return matchesRoom && matchesStatus && matchesSearch;
    }).toList();
  }

  List<_RoomDepositGroup> get _filteredRoomGroups {
    final keyword = _searchController.text.trim().toLowerCase();
    final grouped = <String, List<AdminDepositModel>>{};
    for (final deposit in _deposits) {
      final key = deposit.auctionRoomId.isEmpty
          ? deposit.productId
          : deposit.auctionRoomId;
      grouped.putIfAbsent(key, () => []).add(deposit);
    }

    final groups =
        grouped.entries
            .map((entry) => _RoomDepositGroup(entry.key, entry.value))
            .where((group) {
              final matchesStatus =
                  _selectedStatus == 'ALL' ||
                  group.countByStatus(_selectedStatus) > 0;
              final matchesSearch =
                  keyword.isEmpty ||
                  group.roomId.toLowerCase().contains(keyword) ||
                  group.productName.toLowerCase().contains(keyword) ||
                  group.deposits.any((deposit) {
                    return deposit.id.toLowerCase().contains(keyword) ||
                        deposit.userId.toLowerCase().contains(keyword) ||
                        deposit.username.toLowerCase().contains(keyword) ||
                        deposit.userEmail.toLowerCase().contains(keyword) ||
                        deposit.userFullName.toLowerCase().contains(keyword) ||
                        deposit.transferContent.toLowerCase().contains(keyword);
                  });
              return matchesStatus && matchesSearch;
            })
            .toList()
          ..sort((a, b) => b.pendingCount.compareTo(a.pendingCount));

    return groups;
  }

  Future<void> _reviewDeposit(
    AdminDepositModel deposit, {
    required String status,
    String? adminNote,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    try {
      await _depositService.reviewDeposit(
        accessToken: accessToken,
        depositId: deposit.id,
        status: status,
        adminNote: adminNote,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'APPROVED' ? 'Da duyet tien coc' : 'Da tu choi tien coc',
          ),
        ),
      );
      _loadDeposits();
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
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
    final deposits = _filteredDeposits;
    final roomGroups = _filteredRoomGroups;
    final isRoomDetail = _selectedRoomId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDeposits,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildErrorCard(_errorMessage!)
                    else if (isRoomDetail && deposits.isEmpty)
                      _buildEmptyCard()
                    else if (!isRoomDetail && roomGroups.isEmpty)
                      _buildEmptyRoomCard()
                    else if (!isRoomDetail)
                      ...roomGroups.map(_buildRoomCard)
                    else
                      ...deposits.map(
                        _DepositReviewCard(
                          onApprove: (deposit) => _confirmApprove(deposit),
                          onReject: (deposit) => _openRejectDialog(deposit),
                          onRefund: (deposit) => _confirmRefund(deposit),
                        ).build,
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    final visibleDeposits = _selectedRoomId == null
        ? _deposits
        : _deposits
              .where((deposit) => deposit.auctionRoomId == _selectedRoomId)
              .toList();
    final pendingCount = visibleDeposits
        .where((deposit) => deposit.status == 'PENDING_APPROVAL')
        .length;
    final title = _selectedRoomId == null
        ? 'Quan ly phong coc'
        : 'Phong ${_shortId(_selectedRoomId!)}';
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_selectedRoomId != null) {
              setState(() => _selectedRoomId = null);
              return;
            }
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Duyet rut tien',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminWithdrawalReviewPage(),
              ),
            );
          },
          icon: const Icon(Icons.account_balance_wallet_outlined),
          color: AppColors.primaryBlue,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$pendingCount',
            style: const TextStyle(
              color: Color(0xFF0369A1),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tim theo ma GD, user, san pham...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      'PENDING_APPROVAL': 'Cho duyet',
      'APPROVED': 'Da duyet',
      'REFUNDED': 'Da hoan',
      'SETTLED': 'Tat toan',
      'REJECTED': 'Tu choi',
      'ALL': 'Tat ca',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final selected = _selectedStatus == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primaryBlue
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedStatus = entry.key;
                });
                _loadDeposits();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Khong co giao dich tien coc nao.',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyRoomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Khong co phong dau gia nao co giao dich tien coc.',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRoomCard(_RoomDepositGroup group) {
    return InkWell(
      onTap: () => setState(() => _selectedRoomId = group.roomId),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.meeting_room_outlined,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Phong ${_shortId(group.roomId)}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _RoomStat(label: 'Thanh vien', value: group.totalCount),
                _RoomStat(label: 'Cho duyet', value: group.pendingCount),
                _RoomStat(label: 'Da duyet', value: group.approvedCount),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _RoomStat(label: 'Cho CK', value: group.pendingPaymentCount),
                _RoomStat(label: 'Tu choi', value: group.rejectedCount),
                _RoomStat(label: 'Da hoan', value: group.refundedCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmApprove(AdminDepositModel deposit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyet tien coc'),
        content: Text(
          'Xac nhan user da chuyen ${formatVnd(deposit.requiredAmount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Duyet'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _reviewDeposit(deposit, status: 'APPROVED');
    }
  }

  Future<void> _openRejectDialog(AdminDepositModel deposit) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu choi tien coc'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhap ly do tu choi...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tu choi'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reason == null) return;
    if (reason.isEmpty) {
      _showError('Nhap ly do truoc khi tu choi');
      return;
    }
    _reviewDeposit(deposit, status: 'REJECTED', adminNote: reason);
  }

  Future<void> _confirmRefund(AdminDepositModel deposit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoan tien coc'),
        content: Text(
          'Xac nhan hoan ${formatVnd(deposit.requiredAmount)} ve vi user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoan coc'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _reviewDeposit(
        deposit,
        status: 'REFUNDED',
        adminNote: 'Da hoan tien coc sau khi dau gia ket thuc',
      );
    }
  }
}

class _RoomDepositGroup {
  final String roomId;
  final List<AdminDepositModel> deposits;

  const _RoomDepositGroup(this.roomId, this.deposits);

  String get productName {
    for (final deposit in deposits) {
      if (deposit.productName.isNotEmpty) return deposit.productName;
    }
    return 'San pham ${_shortId(deposits.first.productId)}';
  }

  int get totalCount => deposits.length;
  int get pendingPaymentCount => countByStatus('PENDING_PAYMENT');
  int get pendingCount => countByStatus('PENDING_APPROVAL');
  int get approvedCount => countByStatus('APPROVED');
  int get rejectedCount => countByStatus('REJECTED');
  int get refundedCount => countByStatus('REFUNDED');

  int countByStatus(String status) {
    return deposits.where((deposit) => deposit.status == status).length;
  }
}

class _RoomStat extends StatelessWidget {
  final String label;
  final int value;

  const _RoomStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositReviewCard {
  final void Function(AdminDepositModel deposit) onApprove;
  final void Function(AdminDepositModel deposit) onReject;
  final void Function(AdminDepositModel deposit)? onRefund;

  const _DepositReviewCard({
    required this.onApprove,
    required this.onReject,
    this.onRefund,
  });

  Widget build(AdminDepositModel deposit) {
    final isPending = deposit.status == 'PENDING_APPROVAL';
    final canRefund = deposit.status == 'APPROVED';
    final statusColor = _statusColor(deposit.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.payments_outlined, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GD ${_shortId(deposit.id)}',
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        deposit.paymentSubmittedAt ?? deposit.createdAt,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: deposit.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'So tien', value: formatVnd(deposit.requiredAmount)),
          _InfoRow(label: 'Noi dung CK', value: deposit.transferContent),
          _InfoRow(label: 'User', value: _userDisplay(deposit)),
          _InfoRow(label: 'San pham', value: _productDisplay(deposit)),
          if ((deposit.userNote ?? '').isNotEmpty)
            _InfoRow(label: 'Ghi chu user', value: deposit.userNote!),
          if ((deposit.adminNote ?? '').isNotEmpty)
            _InfoRow(label: 'Ghi chu admin', value: deposit.adminNote!),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onReject(deposit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Tu choi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onApprove(deposit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Duyet vao phong'),
                  ),
                ),
              ],
            ),
          ] else if (canRefund) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onRefund?.call(deposit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Hoan coc ve vi'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF16A34A);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      case 'REFUNDED':
        return const Color(0xFF2563EB);
      case 'SETTLED':
        return const Color(0xFF7C3AED);
      case 'PENDING_PAYMENT':
        return const Color(0xFFD97706);
      default:
        return AppColors.primaryBlue;
    }
  }
}

String _userDisplay(AdminDepositModel deposit) {
  if (deposit.userFullName.isNotEmpty && deposit.userEmail.isNotEmpty) {
    return '${deposit.userFullName} - ${deposit.userEmail}';
  }
  if (deposit.userFullName.isNotEmpty) return deposit.userFullName;
  if (deposit.userEmail.isNotEmpty) return deposit.userEmail;
  if (deposit.username.isNotEmpty) return deposit.username;
  return 'User ${_shortId(deposit.userId)}';
}

String _productDisplay(AdminDepositModel deposit) {
  if (deposit.productName.isNotEmpty) return deposit.productName;
  return 'San pham ${_shortId(deposit.productId)}';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Da duyet';
      case 'REJECTED':
        return 'Tu choi';
      case 'REFUNDED':
        return 'Da hoan';
      case 'SETTLED':
        return 'Tat toan';
      case 'PENDING_PAYMENT':
        return 'Cho CK';
      default:
        return 'Cho duyet';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _shortId(String value) {
  if (value.length <= 8) return value;
  return value.substring(0, 8).toUpperCase();
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Chua cap nhat';
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
}
