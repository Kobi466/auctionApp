import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuctionPriceCard extends StatelessWidget {
  final num startingPrice;
  final num currentPrice;
  final String endTime;

  const AuctionPriceCard({
    super.key,
    required this.startingPrice,
    required this.currentPrice,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPriceInfo('GIÁ GỐC', '${_formatPrice(startingPrice)}kđ'),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildPriceInfo('GIÁ HIỆN TẠI', '${_formatPrice(currentPrice)}kđ', isBlue: true),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildPriceInfo('KẾT THÚC', endTime, isRed: true),
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    // Basic formatting for the demo based on the UI screenshot
    if (price >= 1000000) {
      return (price / 1000000).toStringAsFixed(3).replaceAll('.', '.');
    }
    return price.toString();
  }

  Widget _buildPriceInfo(String label, String value, {bool isBlue = false, bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isBlue 
                ? AppColors.primaryBlue 
                : (isRed ? Colors.red : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}
