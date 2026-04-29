import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductImagePicker extends StatefulWidget {
  const AddProductImagePicker({super.key});

  @override
  State<AddProductImagePicker> createState() => _AddProductImagePickerState();
}

class _AddProductImagePickerState extends State<AddProductImagePicker> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được tải tối đa 10 ảnh')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: \$e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 20, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'HÌNH ẢNH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Picker chính (luôn hiển thị nếu chưa có ảnh nào)
          if (_images.isEmpty)
            _buildMainPicker()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDisplayMainImage(),
                if (_images.length < 10) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...List.generate(
                        _images.length - 1,
                        (index) => _buildSmallImage(_images[index + 1], index + 1),
                      ),
                      _buildSmallPicker(),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      _images.length - 1,
                      (index) => _buildSmallImage(_images[index + 1], index + 1),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMainPicker() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFC7D2FE),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tải ảnh chính lên',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayMainImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: FileImage(File(_images[0].path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _removeImage(0),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC7D2FE),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildSmallImage(XFile image, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
