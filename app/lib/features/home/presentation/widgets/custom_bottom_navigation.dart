import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_session.dart';
import '../pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const HomePage();
        break;
      case 4:
        nextPage = const ProfilePage();
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
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, 'Trang chủ'),
            _buildNavItem(context, 1, Icons.list_alt_rounded, 'Sản phẩm'),
            _buildNavItem(context, 2, Icons.pending_actions_rounded, 'Chờ duyệt'),
            _buildNavItem(context, 3, Icons.gavel_rounded, 'Phòng bid'),
            _buildNavItem(context, 4, Icons.person_rounded, 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
