import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

class AuctionStatsCard extends StatelessWidget {
  final int bidCount;
  final int watcherCount;

  const AuctionStatsCard({
    super.key,
    required this.bidCount,
    required this.watcherCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(
            context,
            Icons.gavel_rounded,
            'Lượt đấu giá',
            '$bidCount',
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            Icons.person_outline_rounded,
            'Người xem',
            '$watcherCount',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppText(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
