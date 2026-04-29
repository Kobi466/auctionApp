import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../widgets/admin_auction_card.dart';
import 'admin_create_auction_page.dart';

class AdminAuctionListPage extends StatefulWidget {
  const AdminAuctionListPage({super.key});

  @override
  State<AdminAuctionListPage> createState() => _AdminAuctionListPageState();
}

class _AdminAuctionListPageState extends State<AdminAuctionListPage> {
  int _selectedTab = 1; // 0: Sắp diễn ra, 1: Đang diễn ra, 2: Đã kết thúc

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          Expanded(
            child: _buildAuctionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateAuctionPage(),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tạo phiên mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 3),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Sắp diễn ra'),
          _buildTabItem(1, 'Đang diễn ra'),
          _buildTabItem(2, 'Đã kết thúc'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm tên sản phẩm...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        AdminAuctionCard(
          imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
          title: 'Rolex Cosmograph Daytona',
          timeRemaining: '04:22:15',
          currentBid: '\$42,500',
          isLive: true,
        ),
        AdminAuctionCard(
          imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
          title: 'Patek Philippe Nautilus 5711',
          timeRemaining: '12:05:48',
          currentBid: '\$118,200',
          isLive: true,
        ),
        AdminAuctionCard(
          imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa',
          title: 'Hermès Birkin 25 Emerald',
          timeRemaining: '01:15:30',
          currentBid: '\$24,900',
          isLive: true,
        ),
      ],
    );
  }
}
