import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/kyc_controller.dart';
import '../steps/step_1_personal_info.dart';
import '../steps/step_2_id_upload.dart';
import '../steps/step_3_face_recognition.dart';
import '../steps/step_4_review_info.dart';
import '../widgets/kyc_progress_stepper.dart';

class KycMainPage extends StatefulWidget {
  const KycMainPage({super.key});

  @override
  State<KycMainPage> createState() => _KycMainPageState();
}

class _KycMainPageState extends State<KycMainPage> {
  late final PageController _pageController;
  late final KycController _kycController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _kycController = KycController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _kycController.initialize();
      if (!mounted) return;

      final message = _kycController.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _kycController.clearMessages();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _kycController.dispose();
    super.dispose();
  }

  Future<void> _onNext(KycController controller) async {
    if (!controller.canProceedCurrentStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui long hoan thanh thong tin cua buoc hien tai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (controller.currentStep < 4) {
      controller.nextStep();
      await _pageController.animateToPage(
        controller.currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final submitted = await controller.submitKyc();
    if (!mounted) return;

    if (submitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.successMessage ?? 'Gui KYC thanh cong'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.errorMessage ?? 'Gui KYC that bai'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onBack(KycController controller) {
    if (controller.currentStep > 1) {
      controller.previousStep();
      _pageController.animateToPage(
        controller.currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KycController>.value(
      value: _kycController,
      child: Consumer<KycController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
                onPressed: () => _onBack(controller),
              ),
              title: const Text(
                'Identity Verification',
                style: TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: KycProgressStepper(
                          currentStep: controller.currentStep,
                          title: controller.stepTitle,
                          progress: controller.progress,
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            Step1PersonalInfo(),
                            Step2IdUpload(),
                            Step3FaceRecognition(),
                            Step4ReviewInfo(),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: controller.isLoading
                ? null
                : _buildBottomButton(controller),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(KycController controller) {
    final isLastStep = controller.currentStep == 4;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSubmitting
                ? null
                : () => _onNext(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: controller.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastStep ? 'Gui xac minh' : 'Tiep theo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isLastStep) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
