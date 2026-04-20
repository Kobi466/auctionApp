import 'package:flutter/material.dart';
import '../../domain/entities/kyc_data_entity.dart';

class KycController extends ChangeNotifier {
  int _currentStep = 1;
  int get currentStep => _currentStep;

  KycDataEntity _kycData = KycDataEntity();
  KycDataEntity get kycData => _kycData;

  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void updateData(KycDataEntity newData) {
    _kycData = newData;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  double get progress => _currentStep / 4.0;
  String get stepTitle {
    switch (_currentStep) {
      case 1: return 'Thông tin cá nhân';
      case 2: return 'Tải lên tài liệu';
      case 3: return 'Xác thực khuôn mặt';
      case 4: return 'Kiểm tra thông tin';
      default: return '';
    }
  }
}
