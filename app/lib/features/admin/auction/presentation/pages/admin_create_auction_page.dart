import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/create_auction/create_auction_product_card.dart';
import '../widgets/create_auction/create_auction_price_form.dart';
import '../widgets/create_auction/create_auction_time_form.dart';
import '../widgets/create_auction/create_auction_info_box.dart';

class AdminCreateAuctionPage extends StatelessWidget {
  const AdminCreateAuctionPage({super.key});

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
                  const CreateAuctionProductCard(
                    imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
                    title: 'Rolex Cosmograph Daytona',
                    sku: 'RLX-2024-001',
                  ),
                  const SizedBox(height: 24),
                  const CreateAuctionPriceForm(),
                  const SizedBox(height: 24),
                  const CreateAuctionTimeForm(),
                  const SizedBox(height: 24),
                  const CreateAuctionInfoBox(),
                  const SizedBox(height: 100), // Khoảng cách cho nút ở dưới
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
                onPressed: () {
                  // TODO: Xử lý tạo phiên đấu giá
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
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
}
