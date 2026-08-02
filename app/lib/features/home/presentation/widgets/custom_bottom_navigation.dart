import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../product/presentation/pages/product_list_page.dart';
import '../../../auction/presentation/pages/join_auction_room_page.dart';
import '../../../pending_request/presentation/pages/pending_request_page.dart';
import '../pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavigation({super.key, required this.selectedIndex});

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const HomePage();
        break;
      case 1:
        nextPage = const ProductListPage();
        break;
      case 2:
        nextPage = const PendingRequestPage();
        break;
      case 3:
        nextPage = const JoinAuctionRoomPage();
        break;
      case 4:
        nextPage = const ProfilePage();
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
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
            _buildNavItem(context, 0, Icons.home_rounded, l10n.navHome),
            _buildNavItem(
              context,
              1,
              Icons.inventory_2_outlined,
              l10n.navProducts,
            ),
            _buildNavItem(
              context,
              2,
              Icons.assignment_outlined,
              l10n.navPending,
            ),
            _buildNavItem(context, 3, Icons.gavel_rounded, l10n.navBidRoom),
            _buildNavItem(context, 4, Icons.person_rounded, l10n.navProfile),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryBlue
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
