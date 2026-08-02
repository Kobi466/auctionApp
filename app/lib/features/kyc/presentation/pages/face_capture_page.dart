import 'package:app/core/localization/app_translator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_colors.dart';

class FaceCapturePage extends StatefulWidget {
  const FaceCapturePage({super.key});

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 1.05,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                          MediaQuery.of(context).size.width * 0.75,
                          MediaQuery.of(context).size.width * 1.05,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 1.05,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue, width: 3),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.75,
                    MediaQuery.of(context).size.width * 1.05,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AppText(
                  'Căn chỉnh khuôn mặt vào giữa khung hình',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    if (!_isInitialized || _controller == null) return;
                    try {
                      final XFile image = await _controller!.takePicture();
                      if (mounted) {
                        Navigator.pop(context, File(image.path));
                      }
                    } catch (e) {
                      debugPrint('Error taking picture: $e');
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
