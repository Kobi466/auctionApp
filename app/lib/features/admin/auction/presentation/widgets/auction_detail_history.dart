import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auction/data/models/bid_model.dart';

class AuctionDetailHistory extends StatelessWidget {
  final List<BidModel> bids;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onViewAll;

  const AuctionDetailHistory({
    super.key,
    required this.bids,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleBids = bids.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lich su dat gia',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (bids.length > visibleBids.length)
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'Xem tat ca',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          _HistoryMessage(
            message: errorMessage!,
            actionLabel: 'Thu lai',
            onAction: onRetry,
          )
        else if (visibleBids.isEmpty)
          const _HistoryMessage(message: 'Chua co luot dat gia nao.')
        else
          ...visibleBids.map(
            (bid) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HistoryItem(bid: bid),
            ),
          ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final BidModel bid;

  const _HistoryItem({required this.bid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bid.isLeading
            ? AppColors.primaryBlue.withValues(alpha: 0.02)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bid.isLeading
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _BidAvatar(bid: bid),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid.userName.isEmpty ? 'Nguoi dung' : bid.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _formatRelativeTime(bid.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatVnd(bid.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: bid.isLeading
                      ? AppColors.primaryBlue
                      : const Color(0xFF1E293B),
                ),
              ),
              if (bid.isLeading)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CAO NHAT',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final difference = DateTime.now().difference(time.toLocal());

    if (difference.inMinutes < 1) return 'Vua xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phut truoc';
    if (difference.inHours < 24) return '${difference.inHours} gio truoc';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _BidAvatar extends StatelessWidget {
  final BidModel bid;

  const _BidAvatar({required this.bid});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = bid.userAvatar?.trim() ?? '';
    final initial = bid.userName.isNotEmpty
        ? bid.userName[0].toUpperCase()
        : '?';

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFEEF2FF),
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HistoryMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
