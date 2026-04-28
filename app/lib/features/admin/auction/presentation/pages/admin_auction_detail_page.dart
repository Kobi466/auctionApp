import 'package:flutter/material.dart';
import '../widgets/auction_detail_actions.dart';
import '../widgets/auction_detail_description.dart';
import '../widgets/auction_detail_history.dart';
import '../widgets/auction_detail_image.dart';
import '../widgets/auction_detail_info.dart';
import '../widgets/auction_detail_stats.dart';

class AdminAuctionDetailPage extends StatelessWidget {
  const AdminAuctionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Chi tiết Đấu giá',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 10),
                  AuctionDetailImage(
                    imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa',
                    isLive: true,
                  ),
                  SizedBox(height: 24),
                  AuctionDetailInfo(
                    category: 'Túi xách cao cấp',
                    productId: '#REB-2024-089',
                    title: 'Hermès Birkin 35 Epsom Blue Sapphire Gold Hardware',
                    currentPrice: '450.000.000đ',
                    timeRemaining: '14:25:08',
                  ),
                  SizedBox(height: 32),
                  AuctionDetailStats(
                    bidCount: 128,
                    viewCount: '1.4k',
                    participantCount: 45,
                  ),
                  SizedBox(height: 32),
                  AuctionDetailHistory(),
                  SizedBox(height: 32),
                  AuctionDetailDescription(
                    description: 'Phiên bản Birkin 35 giới hạn với chất liệu da Epsom bền bỉ, màu Blue Sapphire sang trọng kết hợp cùng khóa vàng 18K. Tình trạng mới 99%, đầy đủ hộp, túi vải và giấy tờ chứng thực từ hãng. Một tác phẩm nghệ thuật thực sự cho những nhà sưu tầm đẳng cấp.',
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const AuctionDetailActions(),
        ],
      ),
    );
  }
}
