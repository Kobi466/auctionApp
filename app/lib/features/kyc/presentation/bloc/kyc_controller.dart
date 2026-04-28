import 'package:flutter/material.dart';

import '../../../auth/data/auth_session.dart';
import '../../data/kyc_repository_impl.dart';
import '../../data/models/kyc_response_model.dart';
import '../../domain/entities/kyc_data_entity.dart';
import '../../domain/repositories/kyc_repository.dart';

class KycController extends ChangeNotifier {
  KycController({
    KycRepository? repository,
  }) : _repository = repository ?? KycRepositoryImpl();

  final KycRepository _repository;

  int _currentStep = 1;
  KycDataEntity _kycData = KycDataEntity();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  String? _status;
  String? _rejectedReason;

  int get currentStep => _currentStep;
  KycDataEntity get kycData => _kycData;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get status => _status;
  String? get rejectedReason => _rejectedReason;

  Future<void> initialize() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMyKyc(accessToken: accessToken);
      if (response != null) {
        _applyResponse(response);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<bool> submitKyc() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _errorMessage = 'Phien dang nhap da het. Vui long dang nhap lai';
      notifyListeners();
      return false;
    }

    if (!canSubmit) {
      _errorMessage = 'Vui long dien day du thong tin va tai len du anh KYC';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.submitKyc(
        accessToken: accessToken,
        kycData: _kycData,
      );
      _applyResponse(response);
      _successMessage = 'Gui KYC thanh cong';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  bool get canProceedCurrentStep {
    switch (_currentStep) {
      case 1:
        return _hasText(_kycData.idNumber) &&
            _hasText(_kycData.fullName) &&
            _hasText(_kycData.dob) &&
            _hasText(_kycData.gender) &&
            _hasText(_kycData.nationality) &&
            _hasText(_kycData.placeOfOrigin) &&
            _hasText(_kycData.residentialAddress);
      case 2:
        return _kycData.idFrontImage != null && _kycData.idBackImage != null;
      case 3:
        return _kycData.faceImage != null;
      case 4:
        return canSubmit;
      default:
        return false;
    }
  }

  bool get canSubmit {
    return _hasText(_kycData.idNumber) &&
        _hasText(_kycData.fullName) &&
        _hasText(_kycData.dob) &&
        _hasText(_kycData.gender) &&
        _hasText(_kycData.nationality) &&
        _hasText(_kycData.placeOfOrigin) &&
        _hasText(_kycData.residentialAddress) &&
        _kycData.idFrontImage != null &&
        _kycData.idBackImage != null &&
        _kycData.faceImage != null;
  }

  double get progress => _currentStep / 4.0;

  String get stepTitle {
    switch (_currentStep) {
      case 1:
        return 'Thong tin ca nhan';
      case 2:
        return 'Tai len tai lieu';
      case 3:
        return 'Xac thuc khuon mat';
      case 4:
        return 'Kiem tra thong tin';
      default:
        return '';
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _applyResponse(KycResponseModel response) {
    _kycData = response.toEntity().copyWith(
      idFrontImage: _kycData.idFrontImage,
      idBackImage: _kycData.idBackImage,
      faceImage: _kycData.faceImage,
    );
    _status = response.status;
    _rejectedReason = response.rejectedReason;
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
