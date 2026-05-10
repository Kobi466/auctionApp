import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auction/presentation/widgets/auction_registration_flow.dart';
import '../../data/models/product_model.dart';
import 'live_auction_card.dart';

class LiveAuctionSection extends StatelessWidget {
  final List<ProductModel> products;

  const LiveAuctionSection({
    super.key,
    required this.products,
  });

  List<ProductModel> get _liveProducts {
    final liveProducts = products
        .where((product) => _effectiveRoomStatus(product) == 'LIVE')
        .toList();

    if (liveProducts.isNotEmpty) {
      return liveProducts.take(5).toList();
    }

    return products
        .where((product) {
          final status = _effectiveRoomStatus(product);
          return status == 'SCHEDULED' || status == 'LIVE';
        })
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _liveProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Đấu giá trực tiếp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cơ hội sở hữu ngay lúc này',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Text(
                'Tất cả',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Chưa có sản phẩm đấu giá',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = items[index];
                return LiveAuctionCard(
                  imageUrl: product.displayImage,
                  title: product.name,
                  currentPrice: product.auctionRoom?.minimumBid == null
                      ? 'Đang cập nhật'
                      : formatVnd(product.auctionRoom?.minimumBid),
                  timeLeft: _formatTimeLeft(product.auctionRoom?.endTime),
                  onRegister: () => AuctionRegistrationFlow.start(
                    context,
                    product: product,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatTimeLeft(DateTime? endTime) {
    if (endTime == null) {
      return '--:--:--';
    }

    final difference = endTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Đã kết thúc';
    }

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _effectiveRoomStatus(ProductModel product) {
    final room = product.auctionRoom;
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
}
