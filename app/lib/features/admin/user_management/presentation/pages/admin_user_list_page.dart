import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../data/sources/admin_user_service.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/admin_user_card.dart';
import 'admin_user_profile_page.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final AdminUserService _adminUserService = AdminUserService(ApiClient());
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminUserEntity> _users = const [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Khong tim thay access token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _adminUserService.getUsers(accessToken: accessToken);
      if (!mounted) return;
      setState(() {
        _users = users;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AdminUserEntity> get _filteredUsers {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      return user.name.toLowerCase().contains(keyword) ||
          (user.email ?? '').toLowerCase().contains(keyword) ||
          (user.phone ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
            'Quan ly nguoi dung',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Theo doi va phe duyet tai khoan he thong',
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
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tim theo ten, email hoac so dien thoai...',
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
            'DANH SACH THANH VIEN',
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
            child: Text(
              '${_users.length} Users',
              style: const TextStyle(
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFF991B1B)),
          ),
        ),
      );
    }

    final users = _filteredUsers;
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          'Khong co nguoi dung nao.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AdminUserCard(
          user: user,
          onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AdminUserProfilePage(user: user),
              ),
            );
            if (updated == true) {
              _loadUsers();
            }
          },
        );
      },
    );
  }
}
