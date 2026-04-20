import '../entities/kyc_data_entity.dart';

abstract class KycRepository {
  Future<void> submitKyc(KycDataEntity kycData);
}
