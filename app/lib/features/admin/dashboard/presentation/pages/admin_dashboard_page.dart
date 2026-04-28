import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../../../auth/data/auth_session.dart';
import '../../data/sources/admin_dashboard_service.dart';
import '../../data/models/admin_dashboard_summary_model.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_auction_item.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../shared/widgets/admin_stat_card.dart';
import '../../../kyc/presentation/pages/kyc_approval_list_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardService _adminDashboardService = AdminDashboardService(ApiClient());
  int _selectedIndex = 0;
  AdminDashboardSummaryModel? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không tìm thấy access token';
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
      if (!mounted) return;
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Chào mừng trở lại, Quản trị viên',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tổng quan hệ thống',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStats(summary),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Phiên nổi bật', () {}),
                  const SizedBox(height: 16),
                  const AdminAuctionItem(
                    imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
                    title: 'Rolex Submariner Date ...',
                    code: '#REB-204',
                    price: '342tr',
                    bids: 24,
                  ),
                  const AdminAuctionItem(
                    imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
                    title: 'Hermes Birkin 30 Togo',
                    code: '#REB-189',
                    price: '568tr',
                    bids: 18,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Hoạt động gần đây',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // _buildActivityList(summary),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavigation(selectedIndex: _selectedIndex),
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
          label: 'USER',
          value: '${summary?.totalUsers ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFDC2626),
          label: 'ĐẤU GIÁ',
          value: '${summary?.totalPendingKyc ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.verified_user_rounded,
          iconColor: const Color(0xFF16A34A),
          label: 'XÁC NHẬN',
          value: '${summary?.totalVerifiedKyc ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFD97706),
          label: 'DUYỆT KYC',
          value: '${summary?.totalRejectedKyc ?? 0}',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KycApprovalListPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
