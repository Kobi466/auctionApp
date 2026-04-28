import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../presentation/admin_access_guard.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../data/admin_service.dart';
import '../../../data/models/admin_dashboard_summary_model.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/admin_auction_item.dart';
import '../widgets/admin_bottom_navigation.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService(ApiClient());
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
        _errorMessage = 'Khong tim thay access token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _adminService.getDashboardSummary(
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
                    'Chao buoi sang, Quan tri vien',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tong quan he thong va cac ho so KYC can xu ly.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStats(summary),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Phien noi bat', () {}),
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
                    'Hoat dong gan day',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityList(summary),
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
          label: 'TONG USER',
          value: '${summary?.totalUsers ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFD97706),
          label: 'KYC CHO DUYET',
          value: '${summary?.totalPendingKyc ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.verified_user_rounded,
          iconColor: const Color(0xFF16A34A),
          label: 'KYC DA DUYET',
          value: '${summary?.totalVerifiedKyc ?? 0}',
        ),
        AdminStatCard(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFDC2626),
          label: 'KYC TU CHOI',
          value: '${summary?.totalRejectedKyc ?? 0}',
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
            'Xem tat ca',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(AdminDashboardSummaryModel? summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _buildActivityItem(
            'Tong user',
            'hien tai la ${summary?.totalUsers ?? 0} tai khoan.',
            'Cap nhat tu backend',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'KYC cho duyet',
            'dang co ${summary?.totalPendingKyc ?? 0} ho so.',
            'Can admin xu ly',
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'KYC da duyet',
            'tong cong ${summary?.totalVerifiedKyc ?? 0} ho so.',
            'Thong ke he thong',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String main, String sub, String time, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: main,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextSpan(text: ' $sub'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
