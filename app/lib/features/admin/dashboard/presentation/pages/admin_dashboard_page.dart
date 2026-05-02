import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../auction/presentation/pages/admin_auction_list_page.dart';
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
          label: 'USERS',
          value: '${summary?.totalUsers ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF2563EB),
          label: 'SAN PHAM',
          value: '${summary?.totalProducts ?? 0}',
          onTap: _openProducts,
        ),
        AdminStatCard(
          icon: Icons.gavel_rounded,
          iconColor: const Color(0xFF16A34A),
          label: 'PHIEN DAU GIA',
          value: '${summary?.totalAuctionRooms ?? 0}',
          onTap: _openAuctions,
        ),
        AdminStatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFD97706),
          label: 'KYC CHO DUYET',
          value: '${summary?.totalPendingKyc ?? 0}',
          onTap: _openKyc,
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
          title: 'Quan ly san pham',
          subtitle: 'Them, sua, xem va xoa san pham dau gia',
          onTap: _openProducts,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.gavel_outlined,
          title: 'Quan ly phien dau gia',
          subtitle: 'Tao va theo doi cac phien dau gia',
          onTap: _openAuctions,
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

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminProductListPage()),
    );
  }

  void _openAuctions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAuctionListPage()),
    );
  }

  void _openKyc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KycApprovalListPage()),
    );
  }
}
