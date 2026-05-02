import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/winner_entity.dart';
import '../pages/admin_winner_detail_page.dart';

class WinnerItemCard extends StatelessWidget {
  final WinnerEntity winner;

  const WinnerItemCard({
    super.key,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminWinnerDetailPage(winner: winner),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          winner.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildWinnerInfo(),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(winner.price),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        color: const Color(0xFFF1F5F9),
        child: winner.imageUrl != null
            ? Image.network(winner.imageUrl!, fit: BoxFit.cover)
            : const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (winner.status) {
      case WinnerStatus.won:
        color = AppColors.primaryBlue;
        break;
      case WinnerStatus.paid:
        color = Colors.green;
        break;
      case WinnerStatus.shipping:
        color = Colors.orange;
        break;
      case WinnerStatus.completed:
        color = Colors.indigo;
        break;
      case WinnerStatus.preparing:
        color = Colors.orangeAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        winner.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWinnerInfo() {
    return Row(
      children: [
        Text(
          winner.winnerName,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
        const SizedBox(width: 4),
        Text(
          winner.subStatusLabel,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDateTime(winner.winningTime),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
        const Text(
          'Vừa xong', // Placeholder for time ago
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(num amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} đ';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, "0")} - ${dt.day}/${dt.month}';
  }
}
