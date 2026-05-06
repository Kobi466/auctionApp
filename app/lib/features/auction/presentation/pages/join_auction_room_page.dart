import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/custom_bottom_navigation.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';

class JoinAuctionRoomPage extends StatefulWidget {
  final String? initialRoomCode;
  final String? initialPassword;

  const JoinAuctionRoomPage({
    super.key,
    this.initialRoomCode,
    this.initialPassword,
  });

  @override
  State<JoinAuctionRoomPage> createState() => _JoinAuctionRoomPageState();
}

class _JoinAuctionRoomPageState extends State<JoinAuctionRoomPage> {
  final _roomCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(),
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
                              'Nhập mã phòng và mật khẩu được cung cấp để tham gia.',
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
                            'MÃ PHÒNG',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _roomCodeController,
                            hintText: 'Ví dụ: BID-8899',
                            suffixIcon: Icons.door_front_door_outlined,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'MẬT KHẨU',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            isPassword: true,
                            suffixIcon: _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          // Join Button with Gradient
                          GestureDetector(
                            onTap: () {
                              // Logic vào phòng
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F7DFF), Color(0xFF3B82F6)],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Vào phòng ngay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.login_rounded, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.verified_user_outlined,
                            color: Color(0xFF94A3B8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'GIAO DỊCH BẢO MẬT 256-BIT SSL',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
    bool isPassword = false,
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
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: InputBorder.none,
          suffixIcon: GestureDetector(
            onTap: onSuffixIconTap,
            child: Icon(suffixIcon, color: const Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}
