import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

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
            _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
            _buildNavItem(1, Icons.list_alt_rounded, 'Sản phẩm'),
            _buildNavItem(2, Icons.pending_actions_rounded, 'Chờ duyệt'),
            _buildNavItem(3, Icons.gavel_rounded, 'Phòng bid'),
            _buildNavItem(4, Icons.person_rounded, 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
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
