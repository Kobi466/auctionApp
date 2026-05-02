import 'package:flutter/material.dart';

import '../../../../auth/data/auth_session.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/product_service.dart';
import '../pages/admin_add_product_page.dart';
import 'admin_product_card.dart';

class AdminProductList extends StatefulWidget {
  const AdminProductList({super.key});

  @override
  State<AdminProductList> createState() => _AdminProductListState();
}

class _AdminProductListState extends State<AdminProductList> {
  final ProductService _productService = ProductService();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<ProductModel>> _loadProducts() {
    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty) {
      return Future.value(const []);
    }
    return _productService.getProducts(accessToken: accessToken);
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa san pham'),
        content: Text('Ban co chac muon xoa "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final accessToken = AuthSession.instance.accessToken ?? '';
      if (accessToken.isEmpty) {
        throw Exception('Chua dang nhap');
      }

      await _productService.deleteProduct(
        accessToken: accessToken,
        productId: product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _productsFuture = _loadProducts();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da xoa san pham')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _editProduct(ProductModel product) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddProductPage(product: product),
      ),
    );

    if (updated == true && mounted) {
      setState(() {
        _productsFuture = _loadProducts();
      });
    }
  }

  void _viewProduct(ProductModel product) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Thuong hieu', product.brand),
              _buildInfoRow('Danh muc', product.categoryId),
              _buildInfoRow('Trang thai', product.status),
              if ((product.provenance ?? '').isNotEmpty)
                _buildInfoRow('Nguon goc', product.provenance!),
              if ((product.authenticity ?? '').isNotEmpty)
                _buildInfoRow('Xac thuc', product.authenticity!),
              if (product.rarityRank != null)
                _buildInfoRow('Do hiem', product.rarityRank.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dong'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(snapshot.error.toString()),
          );
        }

        final products = snapshot.data ?? const <ProductModel>[];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('ChÆ°a cÃ³ sáº£n pháº©m')),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return AdminProductCard(
              imageUrl: product.displayImage,
              title: product.name,
              sku: _shortId(product.id),
              status: product.status,
              category: product.categoryId,
              brand: product.brand,
              onEdit: () => _editProduct(product),
              onView: () => _viewProduct(product),
              onDelete: () => _deleteProduct(product),
            );
          },
        );
      },
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return id.substring(0, 8);
  }
}
