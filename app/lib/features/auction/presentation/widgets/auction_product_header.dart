import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_provider_helper.dart';

class AuctionProductHeader extends StatefulWidget {
  final ProductModel product;

  const AuctionProductHeader({super.key, required this.product});

  @override
  State<AuctionProductHeader> createState() => _AuctionProductHeaderState();
}

class _AuctionProductHeaderState extends State<AuctionProductHeader> {
  int _currentIndex = 0;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    // Kết hợp mainImageUrl và danh sách imageUrls
    _images = [
      if (widget.product.mainImageUrl != null &&
          widget.product.mainImageUrl!.isNotEmpty)
        widget.product.mainImageUrl!,
      ...widget.product.imageUrls,
    ].where((img) => img.isNotEmpty).toSet().toList();

    // Fallback nếu không có ảnh nào
    if (_images.isEmpty) {
      _images = [''];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Widget Carousel ảnh
        _ImageCarousel(
          images: _images,
          currentIndex: _currentIndex,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                '${widget.product.brand.toUpperCase()} • ${widget.product.subTitle ?? "WATCH"}',
                style: TextStyle(
                  color: Color(0xFF4F7DFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              AppText(
                widget.product.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              // Widget Badge thông tin
              Row(
                children: const [
                  _InfoBadge(
                    icon: Icons.check_circle_outline,
                    title: 'TÌNH TRẠNG',
                    value: '99% (Like New)',
                  ),
                  SizedBox(width: 12),
                  _InfoBadge(
                    icon: Icons.verified_outlined,
                    title: 'KIỂM ĐỊNH',
                    value: 'Chính hãng',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return Image(
                image: appImageProvider(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              );
            },
          ),
        ),

        // Chỉ số trang x/y
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText(
              '${currentIndex + 1}/${images.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Thanh Indicator (Line)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: List.generate(
              images.length,
              (index) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBadge({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                  ),
                  AppText(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
