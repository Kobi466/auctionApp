import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/banner_slider.dart';
import '../widgets/live_auction_section.dart';
import '../widgets/ending_soon_section.dart';
import '../widgets/trending_new_section.dart';
import '../widgets/wishlist_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeAppBar(),
              HomeSearchBar(),
              SizedBox(height: 16),
              CategoryList(),
              SizedBox(height: 20),
              BannerSlider(),
              SizedBox(height: 24),
              LiveAuctionSection(),
              SizedBox(height: 24),
              EndingSoonSection(),
              SizedBox(height: 24),
              TrendingNewSection(),
              SizedBox(height: 24),
              WishlistSection(),
              SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
