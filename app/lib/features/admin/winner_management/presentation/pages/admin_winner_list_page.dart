import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../domain/entities/winner_entity.dart';
import '../widgets/winner_item_card.dart';
import '../widgets/winner_search_bar.dart';
import '../widgets/winner_stats_card.dart';
import '../widgets/winner_filter_tabs.dart';

class AdminWinnerListPage extends StatefulWidget {
  const AdminWinnerListPage({super.key});

  @override
  State<AdminWinnerListPage> createState() => _AdminWinnerListPageState();
}

class _AdminWinnerListPageState extends State<AdminWinnerListPage> {
  int _selectedTab = 0;

  final List<WinnerEntity> _staticWinners = [
    WinnerEntity(
      id: '1',
      productName: 'Rolex Submariner ...',
      winnerName: 'Nguyễn Minh Hoàng',
      statusLabel: 'Đã chiến thắng',
      subStatusLabel: 'Đợi thanh toán',
      price: 345000000,
      winningTime: DateTime.now().subtract(const Duration(minutes: 2)),
      status: WinnerStatus.won,
      imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500&q=80',
    ),
    WinnerEntity(
      id: '2',
      productName: 'Hermès Birkin 30',
      winnerName: 'Trần Thị Thu Hà',
      statusLabel: 'Đang giao',
      subStatusLabel: 'Đang vận chuyển',
      price: 820000000,
      winningTime: DateTime.now().subtract(const Duration(minutes: 15)),
      status: WinnerStatus.shipping,
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&q=80',
    ),
    WinnerEntity(
      id: '3',
      productName: 'MacBook Pro M3 M...',
      winnerName: 'Lê Quốc Khánh',
      statusLabel: 'Đã thanh toán',
      subStatusLabel: 'Chờ xác nhận',
      price: 95500000,
      winningTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: WinnerStatus.paid,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&q=80',
    ),
    WinnerEntity(
      id: '4',
      productName: 'Mercedes-Benz G63 A...',
      winnerName: 'Phạm Minh Quân',
      statusLabel: 'Hoàn tất',
      subStatusLabel: 'Đã nhận hàng',
      price: 12500000000,
      winningTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: WinnerStatus.completed,
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=500&q=80',
    ),
    WinnerEntity(
      id: '5',
      productName: 'iPhone 15 Pro Max',
      winnerName: 'Đỗ Anh Tuấn',
      statusLabel: 'Đang chuẩn bị',
      subStatusLabel: 'Đang đóng gói',
      price: 28900000,
      winningTime: DateTime.now().subtract(const Duration(hours: 4)),
      status: WinnerStatus.preparing,
      imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=500&q=80',
    ),
  ];

  List<WinnerEntity> get _filteredWinners {
    if (_selectedTab == 0) return _staticWinners;
    final status = _getStatusFromTab(_selectedTab);
    return _staticWinners.where((w) => w.status == status).toList();
  }

  WinnerStatus? _getStatusFromTab(int index) {
    switch (index) {
      case 1: return WinnerStatus.won;
      case 2: return WinnerStatus.paid;
      case 3: return WinnerStatus.shipping;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final winners = _filteredWinners;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            WinnerSearchBar(onChanged: (v) {}),
            const SizedBox(height: 20),
            WinnerFilterTabs(
              selectedIndex: _selectedTab,
              onTabSelected: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  if (winners.isEmpty) _buildEmptyState()
                  else ...winners.map((w) => WinnerItemCard(winner: w)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
                return;
              }

              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          const Text('Quản lý người thắng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      children: [
        Expanded(child: WinnerStatsCard(label: 'ĐÃ THẮNG', value: '124', color: AppColors.primaryBlue)),
        SizedBox(width: 16),
        Expanded(child: WinnerStatsCard(label: 'HOÀN TẤT', value: '106', color: Color(0xFF6366F1))),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Danh sách gần đây',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Không có dữ liệu')));
  }
}
