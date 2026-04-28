import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../kyc/presentation/pages/kyc_approval_list_page.dart';
import '../../auction/presentation/pages/admin_auction_list_page.dart';

class AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const AdminDashboardPage();
        break;
      case 2:
        nextPage = const AdminAuctionListPage();
        break;
      default:
      // Placeholder for other pages
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => nextPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.dashboard_rounded, 'Dashboard'),
            _buildNavItem(context, 1, Icons.people_alt_rounded, 'Users'),
            _buildNavItem(context, 2, Icons.verified_user_rounded, 'Đấu giá'),
            _buildNavItem(context, 3, Icons.gavel_rounded, 'Giao dịch'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _navigateTo(context,index ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
