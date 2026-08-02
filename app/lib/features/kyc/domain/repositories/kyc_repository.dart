import '../../data/models/kyc_response_model.dart';
import '../entities/kyc_data_entity.dart';

abstract class KycRepository {
  Future<KycResponseModel?> getMyKyc({required String accessToken});

  Future<KycResponseModel> submitKyc({
    required String accessToken,
    required KycDataEntity kycData,
  });
}
