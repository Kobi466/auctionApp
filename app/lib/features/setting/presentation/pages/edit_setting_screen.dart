import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../auth/data/auth_session.dart';
import '../../data/models/profile_response.dart';
import '../../domain/profile_repository_impl.dart';

class EditSettingScreen extends StatefulWidget {
  final ProfileResponse setting;

  const EditSettingScreen({
    super.key,
    required this.setting,
  });

  @override
  State<EditSettingScreen> createState() => _EditSettingScreenState();
}

class _EditSettingScreenState extends State<EditSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController = TextEditingController();

  final ProfileRepositoryImpl _settingRepository = ProfileRepositoryImpl();

  Uint8List? _selectedImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.setting.fullName ?? '';
    _emailController.text = widget.setting.email;
    _phoneController.text = widget.setting.phoneNumber ?? '';
    _avatarController.text = widget.setting.avatar ?? '';
    _selectedImageBytes = _extractImageBytes(widget.setting.avatar);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Khong doc duoc du lieu anh');
      }

      final extension = (file.extension ?? 'png').toLowerCase();
      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/png',
      };

      final encoded = base64Encode(bytes);

      setState(() {
        _selectedImageBytes = bytes;
        _avatarController.text = 'data:$mimeType;base64,$encoded';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSetting() async {
    if (!_formKey.currentState!.validate()) return;

    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy access token'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedSetting = await _settingRepository.updateProfile(
        accessToken: accessToken,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        avatar: _avatarController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(updatedSetting);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  Uint8List? _extractImageBytes(String? avatarValue) {
    final normalized = avatarValue?.trim() ?? '';
    if (!normalized.startsWith('data:image/')) return null;

    final commaIndex = normalized.indexOf(',');
    if (commaIndex == -1) return null;

    try {
      return base64Decode(normalized.substring(commaIndex + 1));
    } on FormatException {
      return null;
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label khong duoc de trong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email khong duoc de trong';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Email khong dung dinh dang';
    }
    return null;
  }

  ImageProvider<Object> _buildImageProvider() {
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    }

    final avatarValue = _avatarController.text.trim();
    if (avatarValue.isEmpty || avatarValue.startsWith('data:image/')) {
      return const NetworkImage('https://i.pravatar.cc/150?img=3');
    }

    return NetworkImage(avatarValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Setting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade900,
                      backgroundImage: _buildImageProvider(),
                    ),
                    FilledButton(
                      onPressed: _pickImage,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Chon anh tu thiet bi'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullNameController,
                validator: (value) => _validateRequired(value, 'Ten'),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ten hien thi',
                  labelStyle: TextStyle(color: Colors.amber),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.amber),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'So dien thoai',
                  labelStyle: TextStyle(color: Colors.amber),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarController,
                keyboardType: TextInputType.url,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Avatar URL / Base64',
                  labelStyle: TextStyle(color: Colors.amber),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedImageBytes = _extractImageBytes(value);
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSetting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isSaving ? 'DANG LUU...' : 'SAVE SETTING'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
