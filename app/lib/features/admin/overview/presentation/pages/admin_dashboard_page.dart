import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_auction_item.dart';
import '../widgets/admin_bottom_navigation.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Chào buổi sáng, Quản trị viên',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hệ thống đang ổn định với 12 phiên mới.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: const [
                      AdminStatCard(
                        icon: Icons.people_rounded,
                        iconColor: Color(0xFF6366F1),
                        label: 'TỔNG USER',
                        value: '12,842',
                      ),
                      AdminStatCard(
                        icon: Icons.verified_user_rounded,
                        iconColor: Color(0xFFD11F66),
                        label: 'KYC CHỜ',
                        value: '48',
                      ),
                      AdminStatCard(
                        icon: Icons.gavel_rounded,
                        iconColor: Color(0xFF3B82F6),
                        label: 'ĐANG ĐẤU',
                        value: '156',
                      ),
                      AdminStatCard(
                        icon: Icons.description_rounded,
                        iconColor: Color(0xFF6366F1),
                        label: 'YÊU CẦU',
                        value: '12',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Phiên nổi bật', () {}),
                  const SizedBox(height: 16),
                  const AdminAuctionItem(
                    imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
                    title: 'Rolex Submariner Date ...',
                    code: '#REB-204',
                    price: '342tr',
                    bids: 24,
                  ),
                  const AdminAuctionItem(
                    imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
                    title: 'Hermès Birkin 30 Togo',
                    code: '#REB-189',
                    price: '568tr',
                    bids: 18,
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Hoạt động gần đây',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: _selectedIndex
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _buildActivityItem('Nguyễn Văn A', 'đã xác minh KYC thành công.', '5 phút trước', Colors.blue),
          const SizedBox(height: 16),
          _buildActivityItem('Yêu cầu phòng Đồng hồ cổ', 'từ Trần Thị B.', '12 phút trước', Colors.purple),
          const SizedBox(height: 16),
          _buildActivityItem('Cảnh báo: Đăng nhập lạ', 'từ IP Hà Nội.', '45 phút trước', Colors.redAccent),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Xem tất cả nhật ký', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String main, String sub, String time, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                  children: [
                    TextSpan(text: main, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    TextSpan(text: ' $sub'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
