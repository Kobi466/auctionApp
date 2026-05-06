import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../deposit/presentation/pages/admin_deposit_review_page.dart';
import '../../kyc/presentation/pages/kyc_approval_list_page.dart';
import '../../auction/presentation/pages/admin_auction_list_page.dart';
import '../../product/presentation/pages/admin_product_list_page.dart';
import '../../user_management/presentation/pages/admin_user_list_page.dart';
import '../../winner_management/presentation/pages/admin_winner_list_page.dart';

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
      case 1:
        nextPage = const AdminUserListPage();
        break;
      case 2:
        nextPage = const AdminProductListPage();
        break;
      case 3:
        nextPage = const AdminAuctionListPage();
        break;
      case 4:
        nextPage = const AdminDepositReviewPage();
        break;
      default:
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
            _buildNavItem(context, 2, Icons.inventory_2_outlined, 'Sản phẩm'),
            _buildNavItem(context, 3, Icons.gavel_rounded, 'Đấu giá'),
            _buildNavItem(context, 4, Icons.payments_outlined, 'Giao dịch'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(context, index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
