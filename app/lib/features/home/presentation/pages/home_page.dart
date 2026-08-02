import 'package:flutter/material.dart';
import '../../../auth/data/auth_session.dart';
import '../../data/models/product_model.dart';
import '../../data/product_service.dart';
import '../widgets/ending_soon_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/live_auction_section.dart';
import '../widgets/custom_bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final accessToken = AuthSession.instance.accessToken ?? '';

    if (accessToken.isNotEmpty) {
      _productsFuture = _productService.getProducts(accessToken: accessToken);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    const SizedBox(height: 20),
                    LiveAuctionSection(products: products),
                    const SizedBox(height: 24),
                    EndingSoonSection(products: products),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 0),
    );
  }
}

class _HomePageState extends _ProjectNameHomePageState {}
