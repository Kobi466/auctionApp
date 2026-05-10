import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_session.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../data/auction_room_service.dart';
import 'auction_room_page.dart';

class JoinAuctionRoomPage extends StatefulWidget {
  final String? initialRoomId;
  final String? initialRoomCode;
  final String? initialPassword;

  const JoinAuctionRoomPage({
    super.key,
    this.initialRoomId,
    this.initialRoomCode,
    this.initialPassword,
  });

  @override
  State<JoinAuctionRoomPage> createState() => _JoinAuctionRoomPageState();
}

class _JoinAuctionRoomPageState extends State<JoinAuctionRoomPage> {
  final AuctionRoomService _auctionRoomService = AuctionRoomService();
  final _roomCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRoomCodeVisible = false;
  bool _isPasswordVisible = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _roomCodeController.text = widget.initialRoomCode ?? '';
    _passwordController.text = widget.initialPassword ?? '';
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();
    final password = _passwordController.text.trim();
    if (roomCode.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhap day du ma phong va mat khau')),
      );
      return;
    }

    if ((widget.initialRoomId ?? '').isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuctionRoomPage(roomId: widget.initialRoomId!),
        ),
      );
      return;
    }

    final accessToken = AuthSession.instance.accessToken ?? '';
    if (accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap')),
      );
      return;
    }

    setState(() => _isJoining = true);
    try {
      final access = await _auctionRoomService.joinAuctionRoom(
        accessToken: accessToken,
        roomCode: roomCode,
        roomPassword: password,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuctionRoomPage(roomId: access.roomId),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Nhap ma phong va mat khau duoc cung cap de tham gia.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'MA PHONG',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _roomCodeController,
                            hintText: 'Vi du: 889900',
                            isSecret: true,
                            isVisible: _isRoomCodeVisible,
                            suffixIcon: _isRoomCodeVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            copyLabel: 'mã phòng',
                            onSuffixIconTap: () {
                              setState(() {
                                _isRoomCodeVisible = !_isRoomCodeVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'MAT KHAU',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '********',
                            isSecret: true,
                            isVisible: _isPasswordVisible,
                            suffixIcon: _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            copyLabel: 'mật khẩu',
                            onSuffixIconTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isJoining ? null : _joinRoom,
                              icon: _isJoining
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                _isJoining ? 'Dang vao...' : 'Vao phong ngay',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: Color(0xFF94A3B8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'GIAO DICH BAO MAT',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(selectedIndex: 3),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData suffixIcon,
    bool isSecret = false,
    bool isVisible = true,
    String? copyLabel,
    VoidCallback? onSuffixIconTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isSecret && !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: InputBorder.none,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: copyLabel == null ? null : 'Sao chép $copyLabel',
                onPressed: copyLabel == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: controller.text.trim()),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã sao chép $copyLabel')),
                        );
                      },
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ),
              IconButton(
                tooltip: isVisible ? 'Ẩn' : 'Hiện',
                onPressed: onSuffixIconTap,
                icon: Icon(suffixIcon, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
