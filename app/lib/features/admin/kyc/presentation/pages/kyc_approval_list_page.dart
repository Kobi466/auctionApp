import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../presentation/admin_access_guard.dart';
import '../../../data/admin_service.dart';
import '../../../data/models/admin_kyc_request_model.dart';
import '../../domain/entities/kyc_request_entity.dart';
import '../../../overview/presentation/widgets/admin_app_bar.dart';
import '../../../overview/presentation/widgets/admin_bottom_navigation.dart';
import '../widgets/kyc_request_card.dart';
import 'kyc_approval_detail_page.dart';

class KycApprovalListPage extends StatefulWidget {
  const KycApprovalListPage({super.key});

  @override
  State<KycApprovalListPage> createState() => _KycApprovalListPageState();
}

class _KycApprovalListPageState extends State<KycApprovalListPage> {
  final AdminService _adminService = AdminService(ApiClient());
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 2;
  bool _isLoading = true;
  String? _errorMessage;
  List<KycRequestEntity> _requests = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
    _loadKycRequests();
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

  Future<void> _loadKycRequests() async {
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
      final models = await _adminService.getKycRequests(accessToken: accessToken);
      if (!mounted) return;
      setState(() {
        _requests = models.map((model) => model.toEntity()).toList();
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

  List<KycRequestEntity> get _filteredRequests {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      return _requests;
    }

    return _requests.where((request) {
      return request.fullName.toLowerCase().contains(keyword) ||
          request.email.toLowerCase().contains(keyword) ||
          request.idNumber.toLowerCase().contains(keyword);
    }).toList();
  }

  int get _pendingCount {
    return _requests.where((request) => request.status == KycStatus.pending).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _filteredRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadKycRequests,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duyet KYC',
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
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: Color(0xFF8B5CF6), size: 8),
                              const SizedBox(width: 8),
                              Text(
                                '$_pendingCount yeu cau moi',
                                style: const TextStyle(
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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Container(
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
                      )
                    else if (filteredRequests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Khong co ho so KYC nao.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      ...filteredRequests.map((request) => KycRequestCard(
                            request: request,
                            onTap: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycApprovalDetailPage(request: request),
                                ),
                              );
                              if (updated == true) {
                                _loadKycRequests();
                              }
                            },
                          )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavigation(selectedIndex: _selectedIndex),
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
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tim kiem nguoi dung...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
