import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../data/sources/admin_user_service.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../widgets/user_kyc_status_card.dart';
import '../widgets/user_profile_header.dart';

class AdminUserProfilePage extends StatefulWidget {
  final AdminUserEntity user;

  const AdminUserProfilePage({super.key, required this.user});

  @override
  State<AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<AdminUserProfilePage> {
  final AdminUserService _adminUserService = AdminUserService(ApiClient());
  late AdminUserEntity _user;
  String? _submittingAction;
  bool _hasUpdated = false;

  bool get _isLocked => _user.accountStatus == AccountStatus.locked;
  bool get _isSubmitting => _submittingAction != null;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _sendNotification() async {
    final draft = await showDialog<_NotificationDraft>(
      context: context,
      builder: (context) => _SendNotificationDialog(
        subtitle: _user.email ?? _user.name,
      ),
    );

    if (draft == null) return;

    final title = draft.title.trim();
    final message = draft.message.trim();

    if (title.isEmpty || message.isEmpty) {
      _showError('Vui long nhap day du tieu de va noi dung');
      return;
    }

    await _runAction('notify', () async {
      await _adminUserService.sendNotification(
        accessToken: _requireAccessToken(),
        userId: _user.id,
        title: title,
        message: message,
      );
      _showSuccess('Da gui thong bao');
    });
  }

  Future<void> _toggleAccountStatus() async {
    final nextActive = _isLocked;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ToggleAccountStatusDialog(
        nextActive: nextActive,
        subtitle: _user.email ?? _user.name,
      ),
    );

    if (reason == null) return;

    await _runAction('status', () async {
      final updatedUser = await _adminUserService.updateUserStatus(
        accessToken: _requireAccessToken(),
        userId: _user.id,
        active: nextActive,
        reason: reason.trim().isEmpty ? null : reason.trim(),
      );

      setState(() {
        _user = updatedUser;
        _hasUpdated = true;
      });

      _showSuccess(nextActive ? 'Da mo khoa tai khoan' : 'Da khoa tai khoan');
    });
  }

  Future<void> _runAction(String actionKey, Future<void> Function() action) async {
    if (_isSubmitting) return;

    setState(() {
      _submittingAction = actionKey;
    });

    try {
      await action();
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _submittingAction = null;
      });
    }
  }

  String _requireAccessToken() {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Khong tim thay access token');
    }
    return accessToken;
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasUpdated);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context, _hasUpdated),
          ),
          title: const Text(
            'Ho so nguoi dung',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              UserProfileHeader(user: _user),
              const SizedBox(height: 24),
              UserKycStatusCard(user: _user),
              const SizedBox(height: 32),
              _buildActionButton(
                onPressed: _isSubmitting ? null : _sendNotification,
                icon: Icons.send_rounded,
                label: 'Gui thong bao',
                color: AppColors.primaryBlue,
                isLoading: _submittingAction == 'notify',
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                onPressed: _isSubmitting ? null : _toggleAccountStatus,
                icon: _isLocked ? Icons.lock_open_rounded : Icons.block_flipped,
                label: _isLocked ? 'Mo khoa tai khoan' : 'Khoa tai khoan',
                color: _isLocked
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFFEE2E2),
                textColor: _isLocked
                    ? const Color(0xFF0369A1)
                    : const Color(0xFFDC2626),
                isOutline: true,
                isLoading: _submittingAction == 'status',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    bool isOutline = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutline
                ? BorderSide(color: textColor.withOpacity(0.2))
                : BorderSide.none,
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Icon(icon, color: textColor, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _NotificationDraft {
  final String title;
  final String message;

  const _NotificationDraft({
    required this.title,
    required this.message,
  });
}

class _SendNotificationDialog extends StatefulWidget {
  final String subtitle;

  const _SendNotificationDialog({required this.subtitle});

  @override
  State<_SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<_SendNotificationDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminProfileDialogScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogHeader(
            icon: Icons.notifications_active_outlined,
            title: 'Gui thong bao',
            subtitle: widget.subtitle,
            backgroundColor: const Color(0xFFE8EEFF),
            iconColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 20),
          _DialogTextField(
            controller: _titleController,
            label: 'Tieu de',
            hintText: 'VD: Cap nhat tai khoan',
          ),
          const SizedBox(height: 12),
          _DialogTextField(
            controller: _messageController,
            label: 'Noi dung',
            hintText: 'Nhap noi dung thong bao...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _DialogActions(
            cancelLabel: 'Huy',
            confirmLabel: 'Gui',
            confirmColor: AppColors.primaryBlue,
            confirmTextColor: Colors.white,
            onConfirm: () => Navigator.pop(
              context,
              _NotificationDraft(
                title: _titleController.text,
                message: _messageController.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleAccountStatusDialog extends StatefulWidget {
  final bool nextActive;
  final String subtitle;

  const _ToggleAccountStatusDialog({
    required this.nextActive,
    required this.subtitle,
  });

  @override
  State<_ToggleAccountStatusDialog> createState() => _ToggleAccountStatusDialogState();
}

class _ToggleAccountStatusDialogState extends State<_ToggleAccountStatusDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.nextActive
        ? const Color(0xFF0369A1)
        : const Color(0xFFDC2626);
    final softColor = widget.nextActive
        ? const Color(0xFFE0F2FE)
        : const Color(0xFFFEE2E2);

    return _AdminProfileDialogScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogHeader(
            icon: widget.nextActive ? Icons.lock_open_rounded : Icons.block_flipped,
            title: widget.nextActive ? 'Mo khoa tai khoan' : 'Khoa tai khoan',
            subtitle: widget.subtitle,
            backgroundColor: softColor,
            iconColor: accentColor,
          ),
          const SizedBox(height: 20),
          _DialogTextField(
            controller: _reasonController,
            label: widget.nextActive ? 'Ghi chu' : 'Ly do khoa',
            hintText: widget.nextActive
                ? 'Nhap ghi chu neu co...'
                : 'Nhap ly do khoa tai khoan...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _DialogActions(
            cancelLabel: 'Huy',
            confirmLabel: widget.nextActive ? 'Mo khoa' : 'Khoa',
            confirmColor: softColor,
            confirmTextColor: accentColor,
            confirmBorderColor: accentColor.withOpacity(0.2),
            onConfirm: () => Navigator.pop(context, _reasonController.text),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileDialogScaffold extends StatelessWidget {
  final Widget child;

  const _AdminProfileDialogScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;

  const _DialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogActions extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final Color confirmTextColor;
  final Color? confirmBorderColor;
  final VoidCallback onConfirm;

  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.confirmTextColor,
    required this.onConfirm,
    this.confirmBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DialogButton(
            label: cancelLabel,
            onPressed: () => Navigator.pop(context),
            backgroundColor: const Color(0xFFF1F5F9),
            textColor: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DialogButton(
            label: confirmLabel,
            onPressed: onConfirm,
            backgroundColor: confirmColor,
            textColor: confirmTextColor,
            borderColor: confirmBorderColor,
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor!),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
