import '../domain/entities/kyc_data_entity.dart';
import '../domain/repositories/kyc_repository.dart';
import 'kyc_service.dart';
import 'models/kyc_request_model.dart';
import 'models/kyc_response_model.dart';

class KycRepositoryImpl implements KycRepository {
  final KycService _service;

  KycRepositoryImpl([KycService? service]) : _service = service ?? KycService();

  @override
  Future<KycResponseModel?> getMyKyc({required String accessToken}) {
    return _service.getMyKyc(accessToken: accessToken);
  }

  @override
  Future<KycResponseModel> submitKyc({
    required String accessToken,
    required KycDataEntity kycData,
  }) async {
    final request = await KycRequestModel.fromEntity(kycData);
    return _service.submitKyc(accessToken: accessToken, request: request);
  }
}
