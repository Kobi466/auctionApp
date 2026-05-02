import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../widgets/user_product_card.dart';
import 'product_detail_page.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductList(), // Tất cả
                  _buildProductList(onlyLive: true), // Đang diễn ra
                  _buildProductList(onlyUpcoming: true), // Sắp diễn ra
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 45,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Đang diễn ra'),
          Tab(text: 'Sắp diễn ra'),
        ],
      ),
    );
  }

  Widget _buildProductList({bool onlyLive = false, bool onlyUpcoming = false}) {
    final allItems = [
      {
        'title': 'MacBook Pro M3 Max 64GB',
        'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
        'time': '00:45:12',
        'price': '64.200kđ',
        'participants': 45,
        'isLive': true,
      },
      {
        'title': 'Hermès Birkin 25 – Blue Nuit',
        'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
        'time': '1h 20m',
        'price': '450.000kđ',
        'participants': 0,
        'isLive': false,
      },
      {
        'title': 'Eames Lounge Chair & ...',
        'image': 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c',
        'time': '2h 45m',
        'price': '112.000kđ',
        'participants': 0,
        'isLive': false,
      },
    ];

    final items = allItems.where((item) {
      if (onlyLive) return item['isLive'] == true;
      if (onlyUpcoming) return item['isLive'] == false;
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return UserProductCard(
          title: item['title'] as String,
          imageUrl: item['image'] as String,
          time: item['time'] as String,
          price: item['price'] as String,
          participants: item['participants'] as int,
          isLive: item['isLive'] as bool,
          onDetails: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductDetailPage()),
            );
          },
          onAction: () {
            // Xử lý đấu giá
          },
        );
      },
    );
  }
}
