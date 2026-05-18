import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
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
  List<ProductModel> _auctionRooms = const [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _loadError;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAuctionRooms();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _loadAuctionRooms(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAuctionRooms({bool silent = false}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    if (!silent && mounted) {
      setState(() {
        _isLoading = _auctionRooms.isEmpty;
        _loadError = null;
      });
    }

    try {
      final rooms = await _auctionService.getAuctionRooms(
        accessToken: AuthSession.instance.accessToken ?? '',
      );
      if (!mounted) return;
      setState(() {
        _auctionRooms = rooms;
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    } finally {
      _isRefreshing = false;
    }
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
          Expanded(child: _buildAuctionList()),
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
            setState(() => _selectedTab = 0);
            await _loadAuctionRooms();
          }
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tao phien moi',
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
          _buildTabItem(0, 'Sap dien ra'),
          _buildTabItem(1, 'Dang dien ra'),
          _buildTabItem(2, 'Da ket thuc'),
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
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tim ten san pham...',
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _auctionRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadAuctionRooms,
                child: const Text('Tai lai'),
              ),
            ],
          ),
        ),
      );
    }

    final products = _filterBySelectedTab(_auctionRooms);

    return RefreshIndicator(
      onRefresh: () => _loadAuctionRooms(silent: true),
      child: products.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 160),
                Center(child: Text('Chua co phien dau gia')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final room = product.auctionRoom;
                return AdminAuctionCard(
                  imageUrl: product.displayImage,
                  title: product.name,
                  timeRemaining: _statusLabel(room?.status),
                  currentBid: formatVnd(room?.minimumBid),
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
                      await _loadAuctionRooms(silent: true);
                    }
                  },
                );
              },
            ),
    );
  }

  List<ProductModel> _filterBySelectedTab(List<ProductModel> products) {
    return products.where((product) {
      final status = product.auctionRoom?.status.toUpperCase();
      if (_selectedTab == 0) {
        return status == 'SCHEDULED';
      }
      if (_selectedTab == 2) {
        return _isEndedStatus(status);
      }
      return status == 'LIVE';
    }).toList();
  }

  bool _isEndedStatus(String? status) {
    return status == 'CLOSED' ||
        status == 'CANCELLED' ||
        status == 'WAITING_WINNER_PAYMENT' ||
        status == 'SOLD' ||
        status == 'FAILED';
  }

  String _statusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'SCHEDULED':
        return 'Sap dien ra';
      case 'LIVE':
        return 'Dang dien ra';
      case 'WAITING_WINNER_PAYMENT':
        return 'Cho nguoi thang thanh toan';
      case 'SOLD':
        return 'Da ban';
      case 'FAILED':
        return 'Dau gia that bai';
      case 'CANCELLED':
        return 'Da huy';
      case 'CLOSED':
        return 'Da ket thuc';
      default:
        return status ?? '';
    }
  }
}
