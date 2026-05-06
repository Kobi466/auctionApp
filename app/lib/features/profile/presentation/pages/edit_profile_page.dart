import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_session.dart';
import '../../../setting/data/models/profile_response.dart';
import '../../../setting/data/profile_service.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/edit_profile_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileResponse? profile;

  const EditProfilePage({
    super.key,
    this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  String _avatar = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fillForm(widget.profile);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa cá nhân',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              EditProfileAvatar(
                imageUrl: _avatarUrl,
                onCameraTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chưa hỗ trợ đổi ảnh tại đây')),
                  );
                },
              ),
              const SizedBox(height: 32),
              EditProfileTextField(
                label: 'Họ và tên',
                controller: _fullNameController,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              EditProfileTextField(
                label: 'Số điện thoại',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              EditProfileTextField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _fillForm(ProfileResponse? profile) {
    _fullNameController.text = profile?.fullName?.trim() ?? '';
    _phoneController.text = profile?.phoneNumber?.trim() ?? '';
    _emailController.text = profile?.email.trim() ?? '';
    _avatar = profile?.avatar?.trim() ?? '';
  }

  String get _avatarUrl {
    if (_avatar.isNotEmpty && !_avatar.startsWith('data:image/')) return _avatar;
    return 'https://i.pravatar.cc/300?u=${widget.profile?.userId ?? 'profile'}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Không tìm thấy access token');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedProfile = await _profileService.updateProfile(
        accessToken: accessToken,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        avatar: _avatar,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin thành công')),
      );
      Navigator.pop(context, updatedProfile);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
