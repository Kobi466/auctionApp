import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auction/presentation/widgets/auction_registration_flow.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/product_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../widgets/user_product_card.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  late final TabController _tabController;
  late Future<List<ProductModel>> _productsFuture;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadProducts() {
    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty) {
      return Future.error('Vui lòng đăng nhập để xem sản phẩm');
    }

    return _productService.getProducts(accessToken: accessToken);
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _loadProducts();
    });
    await _productsFuture;
  }

  void _retryLoadProducts() {
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final products = snapshot.data ?? const <ProductModel>[];
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(products),
                      _buildProductList(products, onlyLive: true),
                      _buildProductList(products, onlyUpcoming: true),
                    ],
                  );
                },
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _keyword = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppTranslator.translate(
                    context,
                    'Tìm kiếm sản phẩm...',
                  ),
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
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: AppTranslator.translate(context, 'Tất cả')),
          Tab(text: AppTranslator.translate(context, 'Đang diễn ra')),
          Tab(text: AppTranslator.translate(context, 'Sắp diễn ra')),
        ],
      ),
    );
  }

  Widget _buildProductList(
    List<ProductModel> products, {
    bool onlyLive = false,
    bool onlyUpcoming = false,
  }) {
    final auctionProducts = products.where((product) {
      final status = _effectiveRoomStatus(product);
      return status != 'CLOSED' && status != 'CANCELLED';
    });

    final items = auctionProducts.where((product) {
      final status = _effectiveRoomStatus(product);
      final matchesTab = onlyLive
          ? status == 'LIVE'
          : onlyUpcoming
          ? status == 'SCHEDULED'
          : true;
      final matchesKeyword =
          _keyword.isEmpty ||
          product.name.toLowerCase().contains(_keyword) ||
          product.brand.toLowerCase().contains(_keyword) ||
          product.categoryId.toLowerCase().contains(_keyword);

      return matchesTab && matchesKeyword;
    }).toList();

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 12),
            Center(
              child: AppText(
                'Không có sản phẩm phù hợp',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          final room = product.auctionRoom;
          final isLive = _effectiveRoomStatus(product) == 'LIVE';

          return UserProductCard(
            title: product.name,
            imageUrl: product.displayImage,
            time: _formatAuctionTime(product),
            price: formatVnd(room?.minimumBid ?? product.startingPrice),
            participants: 0,
            isLive: isLive,
            onDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            onAction: product.auctionRoom == null
                ? null
                : () =>
                      AuctionRegistrationFlow.start(context, product: product),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            AppText(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryLoadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: AppText('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAuctionTime(ProductModel product) {
    final room = product.auctionRoom;
    if (room == null) {
      return _formatPlannedStartTime(product.plannedStartTime);
    }

    final now = DateTime.now();
    final status = _effectiveRoomStatus(product);
    if (status == 'CLOSED') return 'Da ket thuc';
    if (status == 'CANCELLED') return 'Da huy';
    final target = status == 'LIVE' ? room.endTime : room.startTime;
    if (target == null) return status;

    final diff = target.difference(now);
    if (diff.isNegative) {
      return status == 'LIVE' ? 'Sắp kết thúc' : 'Đã bắt đầu';
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _effectiveRoomStatus(ProductModel product) {
    final room = product.auctionRoom;
    if (room == null) return '';

    final now = DateTime.now();
    final endTime = room.endTime;
    if (endTime != null && !now.isBefore(endTime)) {
      return 'CLOSED';
    }

    final startTime = room.startTime;
    if (startTime != null && now.isBefore(startTime)) {
      return 'SCHEDULED';
    }

    return room.status.toUpperCase();
  }

  String _formatPlannedStartTime(DateTime? value) {
    if (value == null) return 'Chua co ngay bat dau';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }
}
