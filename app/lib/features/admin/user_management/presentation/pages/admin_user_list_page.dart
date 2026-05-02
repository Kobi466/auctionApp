import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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
      name: 'Lê Minh Tuấn',
      email: 'minhtuan.le@gmail.com',
      role: 'Thành viên',
      kycStatus: KycStatus.pending,
      accountStatus: AccountStatus.active,
      avatar: 'https://i.pravatar.cc/150?u=tuấn',
    ),
    const AdminUserEntity(
      id: '2',
      name: 'Nguyễn Hồng Hạnh',
      email: 'hanh.nguyen@outlook.com',
      role: 'Thành viên',
      kycStatus: KycStatus.verified,
      accountStatus: AccountStatus.active,
    ),
    const AdminUserEntity(
      id: '3',
      name: 'Trần Văn Hoàng',
      email: 'hoang.tv92@company.com',
      role: 'Thành viên',
      kycStatus: KycStatus.unverified,
      accountStatus: AccountStatus.locked,
    ),
    const AdminUserEntity(
      id: '4',
      name: 'Quách Thu Trang',
      email: 'trang.qt_bidder@gmail.com',
      role: 'Thành viên',
      kycStatus: KycStatus.verified,
      accountStatus: AccountStatus.active,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeaderTitle(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 32),
                  _buildListHeader(),
                  const SizedBox(height: 16),
                  _buildUserList(),
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

  Widget _buildHeaderTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý người dùng',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Theo dõi và phê duyệt tài khoản hệ thống',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc email...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF4F7DFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'DANH SÁCH THÀNH VIÊN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '1,284 Users',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
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
      },
    );
  }
}
