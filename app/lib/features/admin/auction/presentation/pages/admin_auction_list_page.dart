import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../home/data/models/product_model.dart';
import '../../data/admin_auction_service.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../widgets/admin_auction_card.dart';
import 'admin_auction_detail_page.dart';
import 'admin_create_auction_page.dart';

class AdminAuctionListPage extends StatefulWidget {
  const AdminAuctionListPage({super.key});

  @override
  State<AdminAuctionListPage> createState() => _AdminAuctionListPageState();
}

class _AdminAuctionListPageState extends State<AdminAuctionListPage> {
  int _selectedTab = 1;
  final AdminAuctionService _auctionService = AdminAuctionService();
  late Future<List<ProductModel>> _auctionRoomsFuture;

  @override
  void initState() {
    super.initState();
    _loadAuctionRooms();
  }

  void _loadAuctionRooms() {
    _auctionRoomsFuture = _auctionService.getAuctionRooms(
      accessToken: AuthSession.instance.accessToken ?? '',
    );
  }

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
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateAuctionPage(),
            ),
          );
          if (created == true && mounted) {
            setState(() {
              _selectedTab = 0;
              _loadAuctionRooms();
            });
          }
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
    return FutureBuilder<List<ProductModel>>(
      future: _auctionRoomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final products = _filterBySelectedTab(
          snapshot.data ?? const <ProductModel>[],
        );

        if (products.isEmpty) {
          return const Center(child: Text('Chưa có phiên đấu giá'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final room = product.auctionRoom;
            return AdminAuctionCard(
              imageUrl: product.displayImage,
              title: product.name,
              timeRemaining: room?.status ?? '',
              currentBid: _formatMoney(room?.minimumBid),
              isLive: room?.status.toUpperCase() == 'LIVE',
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminAuctionDetailPage(
                      product: product,
                    ),
                  ),
                );
                if (changed == true && mounted) {
                  setState(_loadAuctionRooms);
                }
              },
            );
          },
        );
      },
    );
  }

  List<ProductModel> _filterBySelectedTab(List<ProductModel> products) {
    return products.where((product) {
      final status = product.auctionRoom?.status.toUpperCase();
      if (_selectedTab == 0) {
        return status == 'SCHEDULED';
      }
      if (_selectedTab == 2) {
        return status == 'CLOSED' || status == 'CANCELLED';
      }
      return status == 'LIVE';
    }).toList();
  }

  String _formatMoney(num? value) {
    if (value == null) {
      return '0 VND';
    }
    return '${value.toStringAsFixed(0)} VND';
  }
}
