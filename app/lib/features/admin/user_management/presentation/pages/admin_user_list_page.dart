import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/admin_user_card.dart';
import 'admin_user_profile_page.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final List<AdminUserEntity> _users = [
    const AdminUserEntity(
      id: '1',
      name: 'Nguyễn Văn A',
      role: 'Thành viên',
      kycStatus: KycStatus.verified,
      accountStatus: AccountStatus.active,
      avatar: 'https://i.pravatar.cc/150?u=1',
      email: 'nguyenvan.a@example.com',
      phone: '090 123 4567',
      cccd: '012345678910',
      dob: '20/05/1992',
      address: '123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh',
    ),
    const AdminUserEntity(
      id: '2',
      name: 'Trần Thị B',
      role: 'Đại lý',
      kycStatus: KycStatus.unverified,
      accountStatus: AccountStatus.locked,
      email: 'tranthib@example.com',
      phone: '091 234 5678',
      cccd: '098765432109',
      dob: '15/08/1988',
      address: '456 Đường Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
    ),
    const AdminUserEntity(
      id: '3',
      name: 'Lê Huy',
      role: 'Thành viên',
      kycStatus: KycStatus.pending,
      accountStatus: AccountStatus.active,
      email: 'lehuy@example.com',
      phone: '092 345 6789',
      cccd: '112233445566',
      dob: '10/12/1995',
      address: '789 Đường CMT8, Quận 3, TP. Hồ Chí Minh',
    ),
  ];

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
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  const Text(
                    '342 Người dùng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUserGrid(),
                  const SizedBox(height: 24),
                  _buildFullListButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.tune_rounded, color: Color(0xFF4F46E5)),
        ),
      ],
    );
  }

  Widget _buildUserGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _users.length + 1,
      itemBuilder: (context, index) {
        if (index < _users.length) {
          final user = _users[index];
          return AdminUserCard(
            user: user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminUserProfilePage(user: user),
                ),
              );
            },
          );
        } else {
          return _buildLoadMoreCard();
        }
      },
    );
  }

  Widget _buildLoadMoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF94A3B8), size: 30),
          ),
          const SizedBox(height: 12),
          const Text(
            'Xem thêm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Text(
            'Tải thêm 20 người dùng',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullListButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0052FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Xem toàn bộ danh sách',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
