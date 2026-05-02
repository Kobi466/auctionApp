import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../widgets/product_list_header.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/admin_product_list.dart';
import 'admin_add_product_page.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  int _reloadKey = 0;

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
          Expanded(
            child: SingleChildScrollView(
              child: AdminProductList(key: ValueKey(_reloadKey)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddProductPage(),
            ),
          );
          if (created == true && mounted) {
            setState(() {
              _reloadKey++;
            });
          }
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
