import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_provider_helper.dart';
import '../../../auction/presentation/widgets/auction_registration_flow.dart';
import '../../../home/data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel? product;

  const ProductDetailPage({super.key, this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  ProductModel? get _product => widget.product;

  List<String> get _productImages {
    final product = _product;
    if (product == null) {
      return const [
        'https://images.unsplash.com/photo-1547996160-81dfa63595dd',
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
      ];
    }

    final images = [
      if ((product.mainImageUrl ?? '').trim().isNotEmpty)
        product.mainImageUrl!.trim(),
      ...product.imageUrls.where((url) => url.trim().isNotEmpty),
    ];
    return images.toSet().toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final room = product?.auctionRoom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImageSlider(context),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product == null
                            ? 'ROLEX'
                            : '${product.brand} - ${product.categoryId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product?.name ?? 'Rolex Submariner Date 2023',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Gia khoi diem: ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatVnd(room?.minimumBid ?? product?.startingPrice),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildStartTimeNotice(),
                      const SizedBox(height: 24),
                      _buildInfoGrid(),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'MO TA SAN PHAM',
                        icon: Icons.info_outline,
                        content: _description,
                      ),
                      const SizedBox(height: 16),
                      _buildSpecsSection(),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'NGUON GOC & MINH BACH',
                        icon: Icons.verified_user_outlined,
                        content: _provenance,
                        footer: _buildNFTCertificate(),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildAppBar(context),
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  String get _description {
    final product = _product;
    final description = product?.description ?? product?.shortDescription;
    if (description != null && description.trim().isNotEmpty) {
      return description.trim();
    }
    return 'San pham dang duoc dau gia tren he thong ReBid.';
  }

  String get _provenance {
    final provenance = _product?.provenance;
    if (provenance != null && provenance.trim().isNotEmpty) {
      return provenance.trim();
    }
    return 'San pham da duoc quan tri vien kiem tra thong tin truoc khi dua len san dau gia.';
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleIcon(Icons.arrow_back, onTap: () => Navigator.pop(context)),
          Row(
            children: [
              _buildCircleIcon(Icons.share_outlined),
              const SizedBox(width: 12),
              _buildCircleIcon(Icons.favorite_border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
      ),
    );
  }

  Widget _buildProductImageSlider(BuildContext context) {
    final images = _productImages;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 380,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: images.isEmpty
              ? const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primaryBlue,
                  size: 80,
                )
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60, bottom: 40),
                      child: Image(
                        image: appImageProvider(images[index]),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF94A3B8),
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final product = _product;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildInfoCard(Icons.check_circle_outline, 'TRANG THAI', product?.status ?? 'LIVE'),
        _buildInfoCard(Icons.verified_outlined, 'XAC THUC', product?.authenticity ?? 'Dang kiem tra'),
        _buildInfoCard(Icons.business_rounded, 'THUONG HIEU', product?.brand ?? 'Rolex'),
        _buildInfoCard(Icons.category_outlined, 'DANH MUC', product?.categoryId ?? 'Auction'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F46E5), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    final product = _product;
    final specs = {
      'Thuong hieu': product?.brand ?? 'Rolex',
      'Danh muc': product?.categoryId ?? 'Auction',
      'Do hiem': product?.rarityRank?.toString() ?? 'Chua cap nhat',
      'Trang thai phong': product?.auctionRoom?.status ?? 'Chua co phong',
      'Bat dau': _formatStartTime(product?.effectiveStartTime),
      'Gia coc': formatVnd(product?.auctionRoom?.depositAmount),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, size: 18, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'THONG SO SAN PHAM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...specs.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNFTCertificate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: Color(0xFF2563EB)),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'CHUNG CHI SO DI KEM',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    final room = _product?.auctionRoom;
    final roomStatus = _effectiveRoomStatus;
    final isLive = roomStatus == 'LIVE';
    final isScheduled = roomStatus == 'SCHEDULED';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GIA KHOI DIEM',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVnd(room?.minimumBid ?? _product?.startingPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TRANG THAI',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _roomStatusLabel(roomStatus),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: room == null || _product == null
                    ? null
                    : () => AuctionRegistrationFlow.start(
                          context,
                          product: _product!,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLive
                      ? 'Vao phong dau gia'
                      : isScheduled
                          ? 'Dang ky dat coc'
                          : 'Phien da ket thuc',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _effectiveRoomStatus {
    final room = _product?.auctionRoom;
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

  String _roomStatusLabel(String status) {
    switch (status) {
      case 'LIVE':
        return 'Dang dien ra';
      case 'SCHEDULED':
        return 'Sap dien ra';
      case 'CLOSED':
        return 'Da ket thuc';
      case 'CANCELLED':
        return 'Da huy';
      default:
        return 'Chua co phong';
    }
  }

  Widget _buildStartTimeNotice() {
    final startTime = _product?.effectiveStartTime;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NGAY GIO BAT DAU',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatStartTime(startTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStartTime(DateTime? value) {
    if (value == null) {
      return 'Chua co ngay bat dau';
    }
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

}
