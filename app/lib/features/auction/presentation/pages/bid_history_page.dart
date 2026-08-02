import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../data/models/bid_model.dart';
import '../widgets/bid_history_item.dart';

class BidHistoryPage extends StatelessWidget {
  final List<BidModel> bids;

  const BidHistoryPage({super.key, required this.bids});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        centerTitle: true,
        title: AppText(
          'Lịch sử đấu giá',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bids.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) => BidHistoryItem(bid: bids[index]),
      ),
    );
  }
}
