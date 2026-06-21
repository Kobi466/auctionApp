import 'package:flutter/material.dart';

import '../../../../../core/utils/image_provider_helper.dart';

class AdminProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String sku;
  final String status;
  final String category;
  final String brand;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const AdminProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.sku,
    required this.status,
    required this.category,
    required this.brand,
    this.onEdit,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(status),
                    Text(
                      '#$sku',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $brand',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton(Icons.edit_outlined, onEdit),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.visibility_outlined, onView),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.delete_outline_rounded, onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image(
      image: appImageProvider(imageUrl),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor;
    String text = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'hoạt động':
      case 'active':
        color = const Color(0xFFFDF2F8);
        textColor = const Color(0xFFDB2777);
        text = 'HOẠT ĐỘNG';
        break;
      case 'bản nháp':
      case 'draft':
        color = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        text = 'BẢN NHÁP';
        break;
      case 'đã kết thúc':
      case 'ended':
        color = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        text = 'ĐÃ KẾT THÚC';
        break;
      default:
        color = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}
