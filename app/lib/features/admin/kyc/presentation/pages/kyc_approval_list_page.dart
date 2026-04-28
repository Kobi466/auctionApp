import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../overview/presentation/widgets/admin_app_bar.dart';
import '../../../overview/presentation/widgets/admin_bottom_navigation.dart';
import '../../domain/entities/kyc_request_entity.dart';
import '../widgets/kyc_request_card.dart';
import 'kyc_approval_detail_page.dart';

class KycApprovalListPage extends StatefulWidget {
  const KycApprovalListPage({super.key});

  @override
  State<KycApprovalListPage> createState() => _KycApprovalListPageState();
}

class _KycApprovalListPageState extends State<KycApprovalListPage> {
  int _selectedIndex = 2; // KYC tab

  final List<KycRequestEntity> _mockRequests = [
    KycRequestEntity(
      id: '1',
      fullName: 'Nguyễn Minh Tâm',
      email: 'tam.nm@gmail.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      idNumber: '038200012948',
      dob: '15/08/1994',
      address: '123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh',
      idFrontUrl: 'https://img.freepik.com/free-vector/identity-card-template-design_23-2148960250.jpg',
      idBackUrl: 'https://img.freepik.com/free-vector/identity-card-template-design_23-2148960250.jpg',
      faceImageUrl: 'https://i.pravatar.cc/300?img=11',
      status: KycStatus.pending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    KycRequestEntity(
      id: '2',
      fullName: 'Lê Thị Bảo Ngọc',
      email: 'ngoc.ltb@gmail.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      idNumber: '038200012949',
      dob: '20/05/1996',
      address: '456 Hai Bà Trưng, Quận 3, TP. Hồ Chí Minh',
      idFrontUrl: '',
      idBackUrl: '',
      faceImageUrl: '',
      status: KycStatus.approved,
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Duyệt KYC',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E9FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFF8B5CF6), size: 8),
                            SizedBox(width: 8),
                            Text(
                              '12 yêu cầu mới',
                              style: TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  ..._mockRequests.map((request) => KycRequestCard(
                    request: request,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KycApprovalDetailPage(request: request),
                        ),
                      );
                    },
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm người dùng...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
