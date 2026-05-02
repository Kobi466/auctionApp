import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _productImages = [
    'https://images.unsplash.com/photo-1547996160-81dfa63595dd',
    'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
    'https://images.unsplash.com/photo-1614164185128-e4ec99c436d7',
    'https://images.unsplash.com/photo-1587836374828-4dbaba94ee0e',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Product Image Slider
                _buildProductImageSlider(context),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Brand & Name
                      const Text(
                        'ROLEX • 126610LN',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Rolex Submariner Date 2023',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Text(
                            'Giá khởi điểm: ',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                          ),
                          Text(
                            '18.500.000đ',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Info Grid
                      _buildInfoGrid(),
                      const SizedBox(height: 24),

                      // 4. Mô tả sản phẩm
                      _buildSection(
                        title: 'MÔ TẢ SẢN PHẨM',
                        icon: Icons.info_outline,
                        content: 'Phiên bản Rolex Submariner Date 2023 với kích thước 41mm, vỏ thép Oystersteel bền bỉ. Niềng xoay Cerachrom đen bóng sang trọng.\n\nBộ máy Calibre 3235 tiên tiến cung cấp khả năng dự trữ năng lượng lên đến 70 giờ, độ chính xác -2/+2 giây mỗi ngày.',
                      ),
                      const SizedBox(height: 16),

                      // 5. Thông số kỹ thuật
                      _buildSpecsSection(),
                      const SizedBox(height: 16),

                      // 6. Nguồn gốc
                      _buildSection(
                        title: 'NGUỒN GỐC & TÍNH MINH BẠCH',
                        icon: Icons.verified_user_outlined,
                        content: 'Sản phẩm được đấu giá trực tiếp từ đại lý ủy quyền tại Tokyo, Nhật Bản. Đã qua quy trình kiểm tra 12 bước nghiêm ngặt của đội ngũ chuyên gia ReBid.',
                        footer: _buildNFTCertificate(),
                      ),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Custom AppBar
          _buildAppBar(context),
          
          // Bottom Navigation Bar
          _buildStickyBottomBar(context),
        ],
      ),
    );
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
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Image.network(
                  _productImages[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
        // Indicators
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _productImages.length,
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildInfoCard(Icons.check_circle_outline, 'TÌNH TRẠNG', 'Mới (Unworn)'),
        _buildInfoCard(Icons.verified_outlined, 'KIỂM ĐỊNH', '100% Chính hãng'),
        _buildInfoCard(Icons.public, 'XUẤT XỨ', 'Nhật Bản'),
        _buildInfoCard(Icons.inventory_2_outlined, 'PHỤ KIỆN', 'Hộp, Sổ, Thẻ'),
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
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required String content, Widget? footer}) {
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
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5)),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    final specs = {
      'Thương hiệu': 'Rolex',
      'Bộ sưu tập': 'Submariner',
      'Mã máy': '126610LN-0001',
      'Kích thước': '41 mm',
      'Chống nước': '300m / 1000ft',
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
          Row(
            children: const [
              Icon(Icons.list_alt, size: 18, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text('THÔNG SỐ KỸ THUẬT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          ...specs.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                Text(e.value, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )).toList(),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, size: 16, color: Color(0xFF2563EB)),
          SizedBox(width: 6),
          Text('CHỨNG CHỈ SỐ NFT ĐI KÈM', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('ĐANG ĐẤU GIÁ', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('18.500.000đ', style: TextStyle(fontSize: 18, color: Color(0xFF2563EB), fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('KẾT THÚC SAU', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('02h : 14p : 55s', style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Tham gia phòng đấu giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
