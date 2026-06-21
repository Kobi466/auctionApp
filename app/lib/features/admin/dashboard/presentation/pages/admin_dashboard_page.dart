import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../auction/presentation/pages/admin_auction_list_page.dart';
import '../../../bank/presentation/pages/admin_bank_management_page.dart';
import '../../../deposit/presentation/pages/admin_deposit_review_page.dart';
import '../../../kyc/presentation/pages/kyc_approval_list_page.dart';
import '../../../product/presentation/pages/admin_product_list_page.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../shared/widgets/admin_stat_card.dart';
import '../../data/models/admin_dashboard_summary_model.dart';
import '../../data/sources/admin_dashboard_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardService _adminDashboardService =
      AdminDashboardService(ApiClient());
  AdminDashboardSummaryModel? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ensureAdminAccess(context);
    });
    _loadSummary();
  }

  Future<void> _loadSummary() async {
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
      final summary = await _adminDashboardService.getDashboardSummary(
        accessToken: accessToken,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSummary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tong quan he thong',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStats(_summary),
                    const SizedBox(height: 24),
                    _buildFinanceOverview(_summary),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Quan ly nhanh'),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 0),
    );
  }

  Widget _buildStats(AdminDashboardSummaryModel? summary) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        AdminStatCard(
          icon: Icons.people_rounded,
          iconColor: const Color(0xFF6366F1),
          label: 'Người dùng',
          value: '${summary?.totalUsers ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF2563EB),
          label: 'Sản phẩm',
          value: '${summary?.totalProducts ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.gavel_rounded,
          iconColor: const Color(0xFF16A34A),
          label: 'Xác nhận',
          value: '${summary?.totalAuctionRooms ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFD97706),
          label: 'Duyệt KYC',
          value: '${summary?.totalPendingKyc ?? 0}',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.inventory_2_outlined,
          title: 'Duyet vao phong dau gia',
          subtitle: 'Xac nhan da thanh toan tien coc',
          onTap: _openAuctions,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.account_balance_rounded,
          title: 'Quan ly ngan hang',
          subtitle: 'Them, sua, xoa tai khoan nhan tien',
          onTap: _openBanks,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.verified_user_outlined,
          title: 'Duyet KYC',
          subtitle: 'Kiem tra ho so xac minh nguoi dung',
          onTap: _openKyc,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.3,
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
      ),
    );
  }

  void _openAuctions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDepositReviewPage()),
    );
  }

  Widget _buildFinanceOverview(AdminDashboardSummaryModel? summary) {
    if (_isLoading || _errorMessage != null || summary == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tong loi lo'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _financeChip(
                    'Tien thang',
                    formatVnd(summary.totalNetWinningAmount),
                    Icons.emoji_events_outlined,
                    AppColors.primaryBlue,
                  ),
                  _financeChip(
                    'Tien goc',
                    formatVnd(summary.totalOriginalCost),
                    Icons.inventory_2_outlined,
                    const Color(0xFF64748B),
                  ),
                  _financeChip(
                    'Lai/lo',
                    formatVnd(summary.estimatedNetProfit),
                    Icons.account_balance_wallet_outlined,
                    const Color(0xFF7C3AED),
                  ),
                  _financeChip(
                    'Con phai thu',
                    formatVnd(summary.totalPendingReceivable),
                    Icons.hourglass_top_rounded,
                    const Color(0xFFD97706),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.45,
                children: [
                  _smallMoneyText('Coc dang giu', summary.totalHeldDeposit),
                  _smallMoneyText('Coc mat', summary.totalForfeitedDeposit),
                  _smallMoneyText('Coc da hoan', summary.totalRefundedDeposit),
                  _smallMoneyText('Coc tat toan', summary.totalSettledDeposit),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Bang xep hang dong tien',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (summary.financeRankings.isEmpty)
                const Text(
                  'Chua co phien dau gia co dong tien.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...summary.financeRankings.map(_financeRankingTile),
              const SizedBox(height: 8),
              const Text(
                'Cong thuc: tien thang = gia dau gia - tien coc. Lai/lo = tien thang - tien goc.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financeChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallMoneyText(String label, num value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label\n${formatVnd(value)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _financeRankingTile(AdminFinanceRankingItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isEmpty ? 'San pham dau gia' : item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.winnerName.isEmpty ? 'Chua ro nguoi thang' : item.winnerName} - ${_paymentLabel(item.paymentStatus, item.paymentMethod)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Lai ${formatVnd(item.estimatedProfit)}',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Thang ${formatVnd(item.netWinningAmount)}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Goc ${formatVnd(item.originalCost)}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String? status, String? method) {
    if (method == 'COD') return 'COD';
    switch (status) {
      case 'PAID':
        return 'da xac nhan';
      case 'PAYMENT_SUBMITTED':
        return 'cho doi soat';
      case 'WAITING_PAYMENT':
      case 'PAYMENT_REJECTED':
        return 'cho thanh toan';
      default:
        return 'dang xu ly';
    }
  }

  void _openKyc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KycApprovalListPage()),
    );
  }

  void _openBanks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminBankManagementPage()),
    );
  }
}
