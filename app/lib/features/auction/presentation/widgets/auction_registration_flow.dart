import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/data/models/product_model.dart';
import '../../../kyc/presentation/pages/kyc_main_page.dart';
import '../../../pending_request/presentation/pages/pending_request_page.dart';
import '../../data/auction_participation_service.dart';
import '../../data/models/auction_deposit_model.dart';
import '../../data/models/auction_participation_status_model.dart';
import '../../data/models/auction_payment_config_model.dart';
import '../../data/models/auction_room_access_model.dart';

class AuctionRegistrationFlow {
  static final AuctionParticipationService _service =
      AuctionParticipationService();

  static Future<void> start(
    BuildContext context, {
    required ProductModel product,
  }) async {
    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty) {
      _showSnackBar(context, 'Vui lòng đăng nhập để đăng ký đấu giá');
      return;
    }

    _showLoading(context);
    try {
      final status = await _service.getStatus(
        accessToken: accessToken,
        productId: product.id,
      );
      if (!context.mounted) return;
      Navigator.pop(context);

      final roomStatus = _roomStatus(status.product ?? product);
      if (roomStatus == 'CLOSED' || roomStatus == 'CANCELLED') {
        await _showAuctionClosedDialog(context);
        return;
      }

      if (!status.kycVerified) {
        await _showKycRequiredDialog(context);
        return;
      }

      if (status.roomAccessGranted) {
        await _loadAndShowRoomAccess(
          context,
          accessToken: accessToken,
          productId: product.id,
        );
        return;
      }

      if (status.deposit != null) {
        final depositStatus = status.deposit!.status;
        if (depositStatus == 'PENDING_APPROVAL') {
          await _showPendingApprovalDialog(context);
          return;
        }

        if (depositStatus == 'APPROVED') {
          await _loadAndShowRoomAccess(
            context,
            accessToken: accessToken,
            productId: product.id,
          );
          return;
        }

        if (status.paymentConfig == null) {
          _showSnackBar(
            context,
            'Chưa cấu hình thông tin chuyển khoản',
            isError: true,
          );
          return;
        }

        if (roomStatus == 'LIVE') {
          await _showAuctionAlreadyStartedDialog(context);
          return;
        }

        await _showPaymentDialog(
          context,
          accessToken: accessToken,
          deposit: status.deposit!,
          paymentConfig: status.paymentConfig!,
        );
        return;
      }

      if (roomStatus == 'LIVE') {
        await _showAuctionAlreadyStartedDialog(context);
        return;
      }

      await _showRulesDialog(
        context,
        accessToken: accessToken,
        productId: product.id,
        rules: status.auctionRules,
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        context,
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  static String _roomStatus(ProductModel product) {
    final room = product.auctionRoom;
    if (room == null) return '';

    final now = DateTime.now();
    final startTime = room.startTime;
    final endTime = room.endTime;
    if (endTime != null && !now.isBefore(endTime)) {
      return 'CLOSED';
    }
    if (startTime != null && now.isBefore(startTime)) {
      return 'SCHEDULED';
    }
    return room.status.toUpperCase();
  }

  static void _showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static Future<void> _showKycRequiredDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Cần xác minh KYC'),
        content: AppText(
          'Bạn cần hoàn tất KYC trước khi đăng ký đấu giá vào phòng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KycMainPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Chuyển sang KYC'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showRulesDialog(
    BuildContext context, {
    required String accessToken,
    required String productId,
    required String rules,
  }) {
    bool agreed = false;
    bool submitting = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: AppText('Tiêu chuẩn cộng đồng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: SingleChildScrollView(
                      child: AppText(
                        rules.isEmpty
                            ? 'Vui lòng đọc kỹ quy định trước khi tham gia đấu giá.'
                            : rules,
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: agreed,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: AppText(
                      'Tôi đồng ý với tiêu chuẩn cộng đồng và quy chế đấu giá.',
                    ),
                    onChanged: submitting
                        ? null
                        : (value) {
                            setDialogState(() {
                              agreed = value == true;
                            });
                          },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: AppText('Hủy'),
                ),
                ElevatedButton(
                  onPressed: !agreed || submitting
                      ? null
                      : () async {
                          setDialogState(() {
                            submitting = true;
                          });
                          try {
                            final status = await _service.confirmRules(
                              accessToken: accessToken,
                              productId: productId,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            await _showConfirmedPayment(
                              context,
                              accessToken,
                              status,
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              submitting = false;
                            });
                            _showSnackBar(
                              context,
                              error.toString().replaceFirst('Exception: ', ''),
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : AppText('Tiếp tục'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> _showConfirmedPayment(
    BuildContext context,
    String accessToken,
    AuctionParticipationStatusModel status,
  ) async {
    final deposit = status.deposit;
    final paymentConfig = status.paymentConfig;
    if (deposit == null || paymentConfig == null) {
      _showSnackBar(
        context,
        'Chưa cấu hình thông tin chuyển khoản',
        isError: true,
      );
      return;
    }

    await _showPaymentDialog(
      context,
      accessToken: accessToken,
      deposit: deposit,
      paymentConfig: paymentConfig,
    );
  }

  static Future<void> _loadAndShowRoomAccess(
    BuildContext context, {
    required String accessToken,
    required String productId,
  }) async {
    _showLoading(context);
    try {
      final access = await _service.getRoomAccess(
        accessToken: accessToken,
        productId: productId,
      );
      if (!context.mounted) return;
      Navigator.pop(context);
      await _showRoomAccessDialog(context, access);
    } catch (error) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        context,
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  static Future<void> _showRoomAccessDialog(
    BuildContext context,
    AuctionRoomAccessModel access,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Thông tin vào phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Tiền cọc đã được admin duyệt. Bạn có thể dùng mã phòng và mật khẩu dưới đây để vào phòng đấu giá.',
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Mã phòng', value: access.roomCode),
            _InfoRow(label: 'Mật khẩu', value: access.roomPassword),
            _InfoRow(label: 'Room ID', value: access.roomId),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText('Đóng'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPaymentDialog(
    BuildContext context, {
    required String accessToken,
    required AuctionDepositModel deposit,
    required AuctionPaymentConfigModel paymentConfig,
  }) {
    bool submitting = false;
    final qrUrl = _buildVietQrUrl(paymentConfig, deposit);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: AppText('Chuyển khoản đăng ký'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (qrUrl.isNotEmpty)
                    Center(
                      child: Image.network(
                        qrUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.qr_code_2_rounded,
                          size: 160,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 160,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Ngân hàng', value: paymentConfig.bankName),
                  _InfoRow(
                    label: 'Số tài khoản',
                    value: paymentConfig.accountNumber,
                  ),
                  _InfoRow(
                    label: 'Chủ tài khoản',
                    value: paymentConfig.accountHolderName,
                  ),
                  _InfoRow(
                    label: 'Số tiền',
                    value: formatVnd(deposit.requiredAmount),
                  ),
                  _InfoRow(label: 'Nội dung', value: deposit.transferContent),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: AppText('Đóng'),
              ),
              ElevatedButton(
                onPressed: submitting
                    ? null
                    : () async {
                        setDialogState(() {
                          submitting = true;
                        });
                        try {
                          await _service.submitPayment(
                            accessToken: accessToken,
                            depositId: deposit.id,
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          _showSnackBar(
                            context,
                            'Đã gửi xác nhận chuyển khoản, vui lòng chờ admin duyệt',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PendingRequestPage(),
                            ),
                          );
                        } catch (error) {
                          if (!dialogContext.mounted) return;
                          setDialogState(() {
                            submitting = false;
                          });
                          _showSnackBar(
                            context,
                            error.toString().replaceFirst('Exception: ', ''),
                            isError: true,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : AppText('Đã chuyển khoản'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _showPendingApprovalDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Đang chờ admin duyệt'),
        content: AppText(
          'Bạn đã xác nhận chuyển khoản. Yêu cầu đăng ký đấu giá đang chờ admin kiểm tra tiền cọc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PendingRequestPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Xem chờ duyệt'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showAuctionNotStartedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Chua den gio dau gia'),
        content: AppText(
          'Tien coc cua ban da duoc duyet. Phong se mo khi den thoi gian dau gia.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Da hieu'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showAuctionAlreadyStartedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Phien dau gia da bat dau'),
        content: AppText(
          'Da qua thoi gian dang ky dat coc. Chi tai khoan da duoc duyet truoc do moi co the vao phong.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Da hieu'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showAuctionClosedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('Phien dau gia da ket thuc'),
        content: AppText(
          'San pham nay da qua thoi gian dau gia nen khong the dang ky hoac vao phong.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: AppText('Da hieu'),
          ),
        ],
      ),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  static String _buildVietQrUrl(
    AuctionPaymentConfigModel paymentConfig,
    AuctionDepositModel deposit,
  ) {
    final templateUrl = paymentConfig.qrImageUrl.trim();
    final amount = deposit.requiredAmount.round().toString();
    final transferContent = Uri.encodeQueryComponent(deposit.transferContent);
    final accountName = Uri.encodeQueryComponent(
      paymentConfig.accountHolderName.trim(),
    );

    if (templateUrl.contains('{amount}') ||
        templateUrl.contains('{addInfo}') ||
        templateUrl.contains('{accountName}') ||
        templateUrl.contains('{content}')) {
      return templateUrl
          .replaceAll('{amount}', amount)
          .replaceAll('{addInfo}', transferContent)
          .replaceAll('{content}', transferContent)
          .replaceAll('{accountName}', accountName);
    }

    final bankCode = _resolveVietQrBankCode(paymentConfig.bankName);
    final accountNumber = paymentConfig.accountNumber.trim();
    if (bankCode.isEmpty || accountNumber.isEmpty) {
      return templateUrl;
    }

    return 'https://img.vietqr.io/image/$bankCode-$accountNumber-compact2.png'
        '?amount=$amount'
        '&addInfo=$transferContent'
        '&accountName=$accountName';
  }

  static String _resolveVietQrBankCode(String bankName) {
    final normalized = bankName.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    const aliases = {
      'MB': 'MB',
      'MBBANK': 'MB',
      'MILITARYBANK': 'MB',
      'VIETCOMBANK': 'VCB',
      'VCB': 'VCB',
      'TECHCOMBANK': 'TCB',
      'TCB': 'TCB',
      'BIDV': 'BIDV',
      'VIETINBANK': 'ICB',
      'ICB': 'ICB',
      'AGRIBANK': 'VBA',
      'ACB': 'ACB',
      'SACOMBANK': 'STB',
      'STB': 'STB',
      'VPBANK': 'VPB',
      'VPB': 'VPB',
      'TPBANK': 'TPB',
      'TPB': 'TPB',
    };

    return aliases[normalized] ?? normalized;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: AppText(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
