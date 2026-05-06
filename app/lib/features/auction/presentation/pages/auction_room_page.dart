import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../data/models/bid_model.dart';
import '../widgets/auction_price_card.dart';
import '../widgets/auction_product_header.dart';
import '../widgets/bid_history_item.dart';
import '../widgets/auction_stats_card.dart';
import 'bid_history_page.dart';

class AuctionRoomPage extends StatefulWidget {
  const AuctionRoomPage({super.key});

  @override
  State<AuctionRoomPage> createState() => _AuctionRoomPageState();
}

class _AuctionRoomPageState extends State<AuctionRoomPage> {
  final TextEditingController _bidController = TextEditingController(text: '2460000000');

  // Specific product data as requested with multiple images
  final ProductModel _product = const ProductModel(
    id: 'patek-5711',
    name: 'Patek Philippe Nautilus 5711/1A',
    brand: 'PATEK PHILIPPE',
    subTitle: 'NAUTILUS',
    startingPrice: 2200000000,
    mainImageUrl: 'https://images.patek.com/images/articles/face_white/625/5711_1A_010_1.jpg',
    imageUrls: [
      'https://static.patek.com/images/articles/face_white/1200/5711_1A_010_2.jpg',
      'https://static.patek.com/images/articles/face_white/1200/5711_1A_010_3.jpg',
      'https://static.patek.com/images/articles/face_white/1200/5711_1A_010_4.jpg',
    ],
    categoryId: 'watches',
    tags: ['Luxury', 'Sport'],
    status: 'active',
  );

  // Mock data with more entries to demonstrate "View All"
  final List<BidModel> _mockBids = [
    BidModel(
      id: '1',
      userId: 'u1',
      userName: 'Minh H***',
      amount: 2450000000,
      createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      isLeading: true,
    ),
    BidModel(
      id: '2',
      userId: 'u2',
      userName: 'Tuấn A***',
      amount: 2440000000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    BidModel(
      id: '3',
      userId: 'u3',
      userName: 'Hải Đ***',
      amount: 2420000000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    BidModel(
      id: '4',
      userId: 'u4',
      userName: 'Hoàng M***',
      amount: 2410000000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    BidModel(
      id: '5',
      userId: 'u5',
      userName: 'Nam P***',
      amount: 2400000000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Phòng đấu giá',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'TRỰC TIẾP',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuctionProductHeader(product: _product),
            const SizedBox(height: 8),
            AuctionPriceCard(
              startingPrice: _product.startingPrice,
              currentPrice: 2450000000,
              endTime: '00:45',
            ),
            const SizedBox(height: 16),
            // Ô hiển thị lượt đấu giá và người xem
            const AuctionStatsCard(
              bidCount: 15,
              watcherCount: 128,
            ),
            const SizedBox(height: 24),
            _buildBiddingSection(),
            const SizedBox(height: 24),
            _buildHistorySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 3),
    );
  }

  Widget _buildBiddingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Dẫn đầu: Minh H***',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'BƯỚC GIÁ: +10M',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập giá',
                          ),
                        ),
                      ),
                      const Text(
                        'đ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  foregroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'TỰ ĐỘNG',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F7DFF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'ĐẶT GIÁ NGAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lịch sử đấu giá',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BidHistoryPage(bids: _mockBids),
                    ),
                  );
                },
                child: const Text(
                  'XEM TẤT CẢ',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Only show top 3 bidders in the main view
          ..._mockBids.take(3).map((bid) => BidHistoryItem(bid: bid)).toList(),
        ],
      ),
    );
  }
}
