import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/winner_entity.dart';
import '../widgets/winner_detail_user_info.dart';
import '../widgets/winner_detail_address_card.dart';
import '../widgets/winner_detail_product_card.dart';
import '../widgets/winner_detail_status_timeline.dart';
import '../widgets/winner_detail_bottom_actions.dart';

class AdminWinnerDetailPage extends StatelessWidget {
  final WinnerEntity winner;

  const AdminWinnerDetailPage({
    super.key,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            WinnerDetailUserInfo(winner: winner),
            const SizedBox(height: 16),
            const WinnerDetailAddressCard(),
            const SizedBox(height: 16),
            WinnerDetailProductCard(winner: winner),
            const SizedBox(height: 16),
            const WinnerDetailStatusTimeline(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: const WinnerDetailBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Chi tiết người thắng',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=${winner.id}'),
          ),
        ),
      ],
    );
  }
}
