import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/product_service.dart';
import '../widgets/add_product_image_picker.dart';
import '../widgets/add_product_details_form.dart';

class AdminAddProductPage extends StatefulWidget {
  final ProductModel? product;

  const AdminAddProductPage({
    super.key,
    this.product,
  });

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _provenanceController = TextEditingController();
  final TextEditingController _authenticityController = TextEditingController();
  final TextEditingController _rarityRankController = TextEditingController();
  List<String> _imageUrls = const [];
  bool _isSubmitting = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) {
      return;
    }

    _nameController.text = product.name;
    _brandController.text = product.brand;
    _provenanceController.text = product.provenance ?? '';
    _authenticityController.text = product.authenticity ?? '';
    _rarityRankController.text = product.rarityRank?.toString() ?? '';
    _imageUrls = product.imageUrls;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _provenanceController.dispose();
    _authenticityController.dispose();
    _rarityRankController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final provenance = _provenanceController.text.trim();
    final authenticity = _authenticityController.text.trim();
    final rarityRankText = _rarityRankController.text.trim();
    final rarityRank =
        rarityRankText.isEmpty ? null : int.tryParse(rarityRankText);

    if (name.isEmpty || brand.isEmpty || _imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui long nhap ten, thuong hieu va chon anh'),
        ),
      );
      return;
    }

    if (rarityRankText.isNotEmpty &&
        (rarityRank == null || rarityRank < 1 || rarityRank > 10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Do hiem phai la so tu 1 den 10'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = AuthSession.instance.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('Chua dang nhap');
      }

      final body = {
        'name': name,
        'brand': brand,
        'imageUrls': _imageUrls,
        'categoryId': widget.product?.categoryId ?? 'auction',
        'status': widget.product?.status ?? 'DRAFT',
        if (provenance.isNotEmpty) 'provenance': provenance,
        if (authenticity.isNotEmpty) 'authenticity': authenticity,
        if (rarityRank != null) 'rarityRank': rarityRank,
      };

      if (_isEditing) {
        await _productService.updateProduct(
          accessToken: token,
          productId: widget.product!.id,
          body: body,
        );
      } else {
        await _productService.createProduct(
          accessToken: token,
          body: body,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Da cap nhat san pham' : 'Da them san pham',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Thêm sản phẩm mới',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Điền thông tin chi tiết để chuẩn bị cho phiên đấu giá.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AddProductImagePicker(
                      initialImageUrls: widget.product?.imageUrls ?? const [],
                      onImagesChanged: (imageUrls) {
                        _imageUrls = imageUrls;
                      },
                    ),
                    const SizedBox(height: 24),
                    AddProductDetailsForm(
                      nameController: _nameController,
                      brandController: _brandController,
                      provenanceController: _provenanceController,
                      authenticityController: _authenticityController,
                      rarityRankController: _rarityRankController,
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF1E293B),
                ),
                const SizedBox(width: 8),
                Text(
                  'Quay lại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 8,
                shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Thêm sản phẩm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
