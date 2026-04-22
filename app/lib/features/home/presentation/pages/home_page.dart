import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/product_service.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/ending_soon_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/live_auction_section.dart';
import '../widgets/trending_new_section.dart';
import '../widgets/wishlist_section.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String accessToken;

  const HomePage({
    super.key,
    required this.accessToken,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  int _selectedIndex = 0;
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts(
      accessToken: widget.accessToken,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _productsFuture = _productService.getProducts(
        accessToken: widget.accessToken,
      );
    });
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: _buildPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SafeArea(
          child: Center(child: Text('Danh sach san pham dau gia')),
        );
      case 2:
        return const SafeArea(
          child: Center(child: Text('Cho dau gia (Cho admin xac nhan)')),
        );
      case 3:
        return const SafeArea(
          child: Center(child: Text('Phong dau gia')),
        );
      case 4:
        return const SafeArea(
          child: Center(child: Text('Trang ca nhan')),
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reloadProducts,
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? const <ProductModel>[];

          return RefreshIndicator(
            onRefresh: _reloadProducts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeAppBar(),
                  const HomeSearchBar(),
                  const SizedBox(height: 16),
                  const CategoryList(),
                  const SizedBox(height: 20),
                  const BannerSlider(),
                  const SizedBox(height: 24),
                  LiveAuctionSection(products: products),
                  const SizedBox(height: 24),
                  EndingSoonSection(products: products),
                  const SizedBox(height: 24),
                  TrendingNewSection(products: products),
                  const SizedBox(height: 24),
                  const WishlistSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
