import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../widgets/pending_request_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';

class PendingRequestPage extends StatefulWidget {
  const PendingRequestPage({super.key});

  @override
  State<PendingRequestPage> createState() => _PendingRequestPageState();
}

class _PendingRequestPageState extends State<PendingRequestPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Tất cả (12)', 'Chờ duyệt', 'Đã duyệt'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategories(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildRequestList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 2),
    );
  }



  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm yêu cầu...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestList() {
    final requests = [
      {
        'title': 'Patek Philippe Nautilus 5711/1A',
        'time': '14:30, Hôm nay',
        'image': 'https://images.unsplash.com/photo-1547996160-81dfa63595dd',
      },
      {
        'title': 'Hermès Birkin 30 Epsom Blue',
        'time': '09:15, Hôm nay',
        'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
      },
      {
        'title': 'Kim cương tự nhiên 2.5 Carat VVS1',
        'time': '18:45, Hôm qua',
        'icon': Icons.diamond_outlined,
        'iconBg': const Color(0xFFEEF2FF),
      },
      {
        'title': 'Porsche 911 Carrera S 2023',
        'time': '10:20, Hôm qua',
        'icon': Icons.directions_car_outlined,
        'iconBg': const Color(0xFFF1F5F9),
      },
      {
        'title': 'Vang Château Mouton Rothschil...',
        'time': '15:10, 02/11/2023',
        'icon': Icons.wine_bar_outlined,
        'iconBg': const Color(0xFFF5F3FF),
      },
      {
        'title': 'MacBook Pro M3 Max - Space Bl...',
        'time': '08:30, 01/11/2023',
        'icon': Icons.laptop_chromebook_rounded,
        'iconBg': const Color(0xFFEFF6FF),
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ...requests.map((req) => PendingRequestCard(
              title: req['title'] as String,
              time: req['time'] as String,
              imageUrl: req['image'] as String?,
              placeholderIcon: req['icon'] as IconData?,
              iconBgColor: req['iconBg'] as Color?,
            )),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Xem thêm yêu cầu',
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
                Icon(Icons.keyboard_arrow_down, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
