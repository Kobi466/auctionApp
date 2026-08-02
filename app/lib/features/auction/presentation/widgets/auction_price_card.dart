import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
          _buildPriceInfo(context, 'GIÁ GỐC', formatVnd(startingPrice)),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildPriceInfo(
            context,
            'GIÁ HIỆN TẠI',
            formatVnd(currentPrice),
            isBlue: true,
          ),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildPriceInfo(context, 'KẾT THÚC', endTime, isRed: true),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(
    BuildContext context,
    String label,
    String value, {
    bool isBlue = false,
    bool isRed = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        AppText(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isBlue
                ? AppColors.primaryBlue
                : (isRed
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
