import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PendingRequestCard extends StatelessWidget {
  final String title;
  final String time;
  final String amount;
  final String status;
  final String transferContent;
  final String? adminNote;
  final String? roomCode;
  final String? roomPassword;
  final VoidCallback? onJoinRoom;

  const PendingRequestCard({
    super.key,
    required this.title,
    required this.time,
    required this.amount,
    required this.status,
    required this.transferContent,
    this.adminNote,
    this.roomCode,
    this.roomPassword,
    this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: statusStyle.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              statusStyle.icon,
              color: statusStyle.foreground,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusStyle.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusStyle.label,
                        style: TextStyle(
                          color: statusStyle.foreground,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  transferContent.isEmpty
                      ? 'Chưa có nội dung chuyển khoản'
                      : transferContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Gửi lúc: $time',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                if (adminNote != null && adminNote!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Admin: $adminNote',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                if (status == 'APPROVED') ...[
                  const SizedBox(height: 10),
                  _RoomAccessBox(
                    roomCode: roomCode,
                    roomPassword: roomPassword,
                    onJoinRoom: onJoinRoom,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String value) {
    switch (value) {
      case 'APPROVED':
        return const _StatusStyle(
          label: 'ĐÃ DUYỆT',
          foreground: Color(0xFF047857),
          background: Color(0xFFD1FAE5),
          icon: Icons.verified_rounded,
        );
      case 'REJECTED':
        return const _StatusStyle(
          label: 'BỊ TỪ CHỐI',
          foreground: Color(0xFFB91C1C),
          background: Color(0xFFFEE2E2),
          icon: Icons.cancel_rounded,
        );
      case 'SETTLED':
        return const _StatusStyle(
          label: 'DA TAT TOAN',
          foreground: Color(0xFF7C3AED),
          background: Color(0xFFF3E8FF),
          icon: Icons.verified_outlined,
        );
      case 'PENDING_PAYMENT':
        return const _StatusStyle(
          label: 'CHỜ CHUYỂN KHOẢN',
          foreground: Color(0xFFB45309),
          background: Color(0xFFFEF3C7),
          icon: Icons.account_balance_wallet_outlined,
        );
      default:
        return const _StatusStyle(
          label: 'ĐANG CHỜ DUYỆT',
          foreground: Color(0xFFDB2777),
          background: Color(0xFFFDF2F8),
          icon: Icons.pending_actions_rounded,
        );
    }
  }
}

class _RoomAccessBox extends StatefulWidget {
  final String? roomCode;
  final String? roomPassword;
  final VoidCallback? onJoinRoom;

  const _RoomAccessBox({
    required this.roomCode,
    required this.roomPassword,
    required this.onJoinRoom,
  });

  @override
  State<_RoomAccessBox> createState() => _RoomAccessBoxState();
}

class _RoomAccessBoxState extends State<_RoomAccessBox> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final roomCode = widget.roomCode;
    final roomPassword = widget.roomPassword;
    final hasAccess =
        roomCode != null &&
        roomCode.trim().isNotEmpty &&
        roomPassword != null &&
        roomPassword.trim().isNotEmpty;
    final displayRoomCode = hasAccess && _isVisible
        ? roomCode
        : _maskSecret(roomCode ?? '');
    final displayPassword = hasAccess && _isVisible
        ? roomPassword
        : _maskSecret(roomPassword ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Thông tin vào phòng',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: hasAccess
                    ? () => setState(() => _isVisible = !_isVisible)
                    : null,
                visualDensity: VisualDensity.compact,
                tooltip: _isVisible ? 'Ẩn thông tin' : 'Hiện thông tin',
                icon: Icon(
                  _isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          _AccessLine(
            label: 'Mã phòng',
            value: hasAccess ? displayRoomCode : 'Đang tải',
            copyValue: hasAccess ? roomCode : null,
          ),
          const SizedBox(height: 4),
          _AccessLine(
            label: 'Mật khẩu',
            value: hasAccess ? displayPassword : 'Đang tải',
            copyValue: hasAccess ? roomPassword : null,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton.icon(
              onPressed: hasAccess ? widget.onJoinRoom : null,
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Vào phòng bid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskSecret(String value) {
    final length = value.trim().isEmpty ? 8 : value.trim().length;
    final maskLength = length < 6 ? 6 : length;
    return List.filled(maskLength, '*').join();
  }
}

class _AccessLine extends StatelessWidget {
  final String label;
  final String value;
  final String? copyValue;

  const _AccessLine({required this.label, required this.value, this.copyValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: copyValue == null
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: copyValue!));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Đã sao chép $label')));
                },
          visualDensity: VisualDensity.compact,
          tooltip: 'Sao chép $label',
          icon: const Icon(
            Icons.copy_rounded,
            size: 16,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });
}
