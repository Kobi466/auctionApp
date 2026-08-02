import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/product_model.dart';
import 'ending_soon_card.dart';

class EndingSoonSection extends StatelessWidget {
  final List<ProductModel> products;

  const EndingSoonSection({super.key, required this.products});

  List<ProductModel> get _endingSoonProducts {
    final items =
        products
            .where(
              (product) =>
                  _effectiveRoomStatus(product) == 'LIVE' &&
                  product.auctionRoom?.endTime != null,
            )
            .toList()
          ..sort((first, second) {
            final firstEndTime = first.auctionRoom!.endTime!;
            final secondEndTime = second.auctionRoom!.endTime!;
            return firstEndTime.compareTo(secondEndTime);
          });

    return items.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _endingSoonProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppText(
                    'Sap ket thuc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4),
                  AppText(
                    'Chi con vai phut cuoi',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF2563EB),
                size: 20,
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
                child: AppText(
                  'Chua co san pham sap ket thuc',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = items[index];
                return EndingSoonCard(
                  imageUrl: product.displayImage,
                  title: product.name,
                  price: product.auctionRoom?.minimumBid == null
                      ? 'Dang cap nhat'
                      : formatVnd(product.auctionRoom?.minimumBid),
                  timeLeft: _formatTimeLeft(product.auctionRoom?.endTime),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatTimeLeft(DateTime? endTime) {
    if (endTime == null) {
      return '--';
    }

    final difference = endTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'HET HAN';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours} GIO';
    }

    final minutes = difference.inMinutes;
    if (minutes > 0) {
      return '$minutes PHUT';
    }

    return '${difference.inSeconds.clamp(0, 59)} GIAY';
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
