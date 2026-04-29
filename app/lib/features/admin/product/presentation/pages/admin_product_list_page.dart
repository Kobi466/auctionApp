import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../widgets/product_list_header.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/admin_product_list.dart';
import 'admin_add_product_page.dart';

class AdminProductListPage extends StatelessWidget {
  const AdminProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          const SizedBox(height: 20),
          const ProductListHeader(),
          const SizedBox(height: 16),
          const ProductSearchBar(),
          const SizedBox(height: 16),
          const Expanded(
            child: SingleChildScrollView(
              child: AdminProductList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddProductPage(),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm sản phẩm',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 2),
    );
  }
}
