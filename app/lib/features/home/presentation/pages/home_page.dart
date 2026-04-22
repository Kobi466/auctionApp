import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/banner_slider.dart';
import '../widgets/live_auction_section.dart';
import '../widgets/ending_soon_section.dart';
import '../widgets/trending_new_section.dart';
import '../widgets/wishlist_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(), // 0: Trang chủ
      const Center(child: Text('Danh sách sản phẩm đấu giá')), // 1: Sản phẩm
      const Center(child: Text('Chờ đấu giá (Chờ admin xác nhận)')), // 2: Chờ xác nhận
      const Center(child: Text('Phòng đấu giá')), // 3: Phòng bid
      const Center(child: Text('Trang cá nhân')), // 4: Cá nhân
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý thêm sản phẩm mới
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
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
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeAppBar(),
            HomeSearchBar(),
            SizedBox(height: 16),
            CategoryList(),
            SizedBox(height: 20),
            BannerSlider(),
            SizedBox(height: 24),
            LiveAuctionSection(),
            SizedBox(height: 24),
            EndingSoonSection(),
            SizedBox(height: 24),
            TrendingNewSection(),
            SizedBox(height: 24),
            WishlistSection(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
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
