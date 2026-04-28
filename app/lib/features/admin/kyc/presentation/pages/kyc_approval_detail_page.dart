import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../data/sources/admin_kyc_service.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../domain/entities/kyc_request_entity.dart';
import '../widgets/kyc_detail_image_card.dart';
import '../widgets/kyc_detail_section_card.dart';
import '../widgets/kyc_review_section.dart';

class KycApprovalDetailPage extends StatefulWidget {
  final KycRequestEntity request;

  const KycApprovalDetailPage({
    super.key,
    required this.request,
  });

  @override
  State<KycApprovalDetailPage> createState() => _KycApprovalDetailPageState();
}

class _KycApprovalDetailPageState extends State<KycApprovalDetailPage> {
  final AdminKycService _adminKycService = AdminKycService(ApiClient());
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _reviewKyc({
    required String status,
    String? rejectedReason,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Không tìm thấy access token');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _adminKycService.reviewKyc(
        accessToken: accessToken,
        kycDetailId: widget.request.id,
        status: status,
        rejectedReason: rejectedReason,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'VERIFIED'
                ? 'Đã duyệt hồ sơ KYC'
                : 'Đã từ chối hồ sơ KYC',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _submitRejection() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _showError('Nhập lý do trước khi từ chối');
      return;
    }

    _reviewKyc(
      status: 'REJECTED',
      rejectedReason: reason,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

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
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: Color(0xFF1E293B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quay lại',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    request.fullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  KycDetailSectionCard(
                    title: 'THÔNG TIN CÁ NHÂN',
                    children: [
                      _buildInfoRow('Số CCCD/ID', request.idNumber),
                      _buildInfoRow('Ngày sinh', request.dob),
                      _buildInfoRow('Địa chỉ thường trú', request.address),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TÀI LIỆU XÁC THỰC',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: KycDetailImageCard(
                          label: 'Mặt trước CCCD',
                          imageValue: request.idFrontUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KycDetailImageCard(
                          label: 'Mặt sau CCCD',
                          imageValue: request.idBackUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  KycDetailImageCard(
                    label: 'Ảnh chân dung',
                    imageValue: request.faceImageUrl,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 32),
                  KycReviewSection(
                    reasonController: _reasonController,
                    isSubmitting: _isSubmitting,
                    updatedAgo: _getTimeAgo(request.updatedAt),
                    onApprove: () => _reviewKyc(status: 'VERIFIED'),
                    onReject: _submitRejection,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 2),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} phút trước';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours} giờ trước';
    }
    return '${duration.inDays} ngày trước';
  }
}
