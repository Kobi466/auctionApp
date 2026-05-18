import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/product_service.dart';
import '../../data/admin_auction_service.dart';
import '../widgets/create_auction/create_auction_product_card.dart';
import '../widgets/create_auction/create_auction_price_form.dart';
import '../widgets/create_auction/create_auction_time_form.dart';
import '../widgets/create_auction/create_auction_info_box.dart';

class AdminCreateAuctionPage extends StatefulWidget {
  const AdminCreateAuctionPage({super.key});

  @override
  State<AdminCreateAuctionPage> createState() => _AdminCreateAuctionPageState();
}

class _AdminCreateAuctionPageState extends State<AdminCreateAuctionPage> {
  final ProductService _productService = ProductService();
  final AdminAuctionService _auctionService = AdminAuctionService();
  final TextEditingController _minimumBidController = TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();

  ProductModel? _selectedProduct;
  List<ProductModel> _products = const [];
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));
  bool _loadingProducts = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _minimumBidController.dispose();
    _depositAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final token = AuthSession.instance.accessToken ?? '';
      final products = await _productService.getProducts(accessToken: token);
      if (!mounted) {
        return;
      }
      final availableProducts = products
          .where((product) => product.auctionRoom == null)
          .toList();
      setState(() {
        _products = availableProducts;
        _selectedProduct = availableProducts.isNotEmpty
            ? availableProducts.first
            : null;
        _syncPriceFromSelectedProduct();
        _loadingProducts = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingProducts = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _selectProduct() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chua co san pham co the tao phong')),
      );
      return;
    }

    final selected = await showModalBottomSheet<ProductModel>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(product.brand),
                onTap: () => Navigator.pop(context, product),
              );
            },
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedProduct = selected;
        _syncPriceFromSelectedProduct();
      });
    }
  }

  void _syncPriceFromSelectedProduct() {
    final price = _selectedProduct?.startingPrice ?? 0;
    _minimumBidController.text = formatMoneyInput(price);
    _depositAmountController.text = formatMoneyInput(price);
  }

  Future<void> _createAuctionRoom() async {
    final product = _selectedProduct;

    if (product == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui long chon san pham')));
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final token = AuthSession.instance.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('Chua dang nhap');
      }

      await _auctionService.createAuctionRoom(
        accessToken: token,
        productId: product.id,
        minimumBid: product.startingPrice,
        depositAmount: product.startingPrice,
        startTime: _startTime,
        endTime: _endTime,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da tao phong dau gia')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _selectedProduct;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo phiên đấu giá',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loadingProducts)
                    const Center(child: CircularProgressIndicator())
                  else
                    CreateAuctionProductCard(
                      imageUrl: product?.displayImage ?? '',
                      title: product?.name ?? 'Chọn sản phẩm',
                      sku: product == null ? '---' : _shortId(product.id),
                      onTap: _selectProduct,
                    ),
                  const SizedBox(height: 24),
                  CreateAuctionPriceForm(
                    minimumBidController: _minimumBidController,
                    depositAmountController: _depositAmountController,
                    lockMinimumBid: true,
                    lockDepositAmount: true,
                  ),
                  const SizedBox(height: 24),
                  CreateAuctionTimeForm(
                    onStartTimeChanged: (value) => _startTime = value,
                    onEndTimeChanged: (value) => _endTime = value,
                  ),
                  const SizedBox(height: 24),
                  const CreateAuctionInfoBox(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _createAuctionRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                      ),
                label: const Text(
                  'Tạo phiên đấu giá',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return id.substring(0, 8);
  }
}
