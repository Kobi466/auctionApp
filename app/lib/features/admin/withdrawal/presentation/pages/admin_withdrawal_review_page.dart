import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../profile/data/models/withdrawal_request_model.dart';
import '../../../../profile/data/withdrawal_service.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';

class AdminWithdrawalReviewPage extends StatefulWidget {
  const AdminWithdrawalReviewPage({super.key});

  @override
  State<AdminWithdrawalReviewPage> createState() =>
      _AdminWithdrawalReviewPageState();
}

class _AdminWithdrawalReviewPageState extends State<AdminWithdrawalReviewPage> {
  final WithdrawalService _withdrawalService = WithdrawalService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'PENDING';
  List<WithdrawalRequestModel> _withdrawals = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadWithdrawals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWithdrawals() async {
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
      final withdrawals = await _withdrawalService.getWithdrawals(
        accessToken: accessToken,
        status: _selectedStatus == 'ALL' ? null : _selectedStatus,
      );
      if (!mounted) return;
      setState(() => _withdrawals = withdrawals);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<WithdrawalRequestModel> get _filteredWithdrawals {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _withdrawals;
    return _withdrawals.where((withdrawal) {
      return withdrawal.id.toLowerCase().contains(keyword) ||
          withdrawal.userEmail.toLowerCase().contains(keyword) ||
          withdrawal.userFullName.toLowerCase().contains(keyword) ||
          withdrawal.bankName.toLowerCase().contains(keyword) ||
          withdrawal.accountNumber.toLowerCase().contains(keyword);
    }).toList();
  }

  Future<void> _reviewWithdrawal(
    WithdrawalRequestModel withdrawal, {
    required String status,
    String? adminNote,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    try {
      await _withdrawalService.reviewWithdrawal(
        accessToken: accessToken,
        withdrawalId: withdrawal.id,
        status: status,
        adminNote: adminNote,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'COMPLETED'
              ? 'Da xac nhan admin da bank'
              : 'Da tu choi yeu cau rut tien'),
        ),
      );
      _loadWithdrawals();
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
    final withdrawals = _filteredWithdrawals;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadWithdrawals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildFilterChips(),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _MessageCard(message: _errorMessage!)
                    else if (withdrawals.isEmpty)
                      const _MessageCard(message: 'Khong co yeu cau rut tien.')
                    else
                      ...withdrawals.map(
                        (withdrawal) => _WithdrawalAdminCard(
                          withdrawal: withdrawal,
                          onComplete: () => _confirmComplete(withdrawal),
                          onReject: () => _openRejectDialog(withdrawal),
                        ),
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
    final pendingCount =
        _withdrawals.where((withdrawal) => withdrawal.status == 'PENDING').length;
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Duyet rut tien',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$pendingCount cho chuyen',
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tim user, ngan hang, so tai khoan...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = {
      'PENDING': 'Cho chuyen',
      'COMPLETED': 'Da bank',
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
              selectedColor: AppColors.primaryBlue.withOpacity(0.12),
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryBlue : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primaryBlue.withOpacity(0.2)
                    : const Color(0xFFE2E8F0),
              ),
              onSelected: (_) {
                setState(() => _selectedStatus = entry.key);
                _loadWithdrawals();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _confirmComplete(WithdrawalRequestModel withdrawal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xac nhan da bank'),
        content: Text(
          'Ban da bank ${formatVnd(withdrawal.amount)} den ${withdrawal.accountNumber}?',
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
            child: const Text('Da bank'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _reviewWithdrawal(
        withdrawal,
        status: 'COMPLETED',
        adminNote: 'Admin da bank theo thong tin user cung cap',
      );
    }
  }

  Future<void> _openRejectDialog(WithdrawalRequestModel withdrawal) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu choi rut tien'),
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
    _reviewWithdrawal(withdrawal, status: 'REJECTED', adminNote: reason);
  }
}

class _WithdrawalAdminCard extends StatelessWidget {
  final WithdrawalRequestModel withdrawal;
  final VoidCallback onComplete;
  final VoidCallback onReject;

  const _WithdrawalAdminCard({
    required this.withdrawal,
    required this.onComplete,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(withdrawal.status);
    final isPending = withdrawal.status == 'PENDING';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.account_balance_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _userDisplay(withdrawal),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _statusLabel(withdrawal.status),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'So tien', value: formatVnd(withdrawal.amount)),
          _InfoRow(label: 'Ngan hang', value: withdrawal.bankName),
          _InfoRow(label: 'So TK', value: withdrawal.accountNumber),
          _InfoRow(label: 'Chu TK', value: withdrawal.accountHolderName),
          if ((withdrawal.branchName ?? '').isNotEmpty)
            _InfoRow(label: 'Chi nhanh', value: withdrawal.branchName!),
          if ((withdrawal.userNote ?? '').isNotEmpty)
            _InfoRow(label: 'Ghi chu', value: withdrawal.userNote!),
          if ((withdrawal.adminNote ?? '').isNotEmpty)
            _InfoRow(label: 'Admin', value: withdrawal.adminNote!),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                    child: const Text('Tu choi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Da bank'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Da bank';
      case 'REJECTED':
        return 'Tu choi';
      default:
        return 'Cho chuyen';
    }
  }

  String _userDisplay(WithdrawalRequestModel withdrawal) {
    if (withdrawal.userFullName.isNotEmpty && withdrawal.userEmail.isNotEmpty) {
      return '${withdrawal.userFullName} - ${withdrawal.userEmail}';
    }
    if (withdrawal.userFullName.isNotEmpty) return withdrawal.userFullName;
    if (withdrawal.userEmail.isNotEmpty) return withdrawal.userEmail;
    if (withdrawal.username.isNotEmpty) return withdrawal.username;
    return 'User ${_shortId(withdrawal.userId)}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
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

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


String _shortId(String value) {
  if (value.length <= 8) return value;
  return value.substring(0, 8).toUpperCase();
}
