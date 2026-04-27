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

class HomePage extends StatefulWidget {
  final String? accessToken;

  const HomePage({
    super.key,
    this.accessToken,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ProjectNameHomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (widget.accessToken != null && widget.accessToken!.isNotEmpty) {
      _productsFuture = _productService.getProducts(
        accessToken: widget.accessToken!,
      );
    } else {
      _productsFuture = Future.value([]);
    }
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _loadProducts();
    });
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: SafeArea(
        child: FutureBuilder<List<ProductModel>>(
          future: _productsFuture,
          builder: (context, snapshot) {
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 0),
    );
  }
}

class _HomePageState extends _ProjectNameHomePageState {}
