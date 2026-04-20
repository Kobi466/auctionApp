import '../../domain/entities/kyc_data_entity.dart';

class KycRequestModel {
  final String idNumber;
  final String fullName;
  final String dob;
  final String gender;
  final String nationality;
  final String placeOfOrigin;
  final String residentialAddress;
  
  // Images are usually handled as MultiPart files in the datasource, 
  // so we just pass paths or files there.

  KycRequestModel({
    required this.idNumber,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.nationality,
    required this.placeOfOrigin,
    required this.residentialAddress,
  });

  factory KycRequestModel.fromEntity(KycDataEntity entity) {
    return KycRequestModel(
      idNumber: entity.idNumber ?? '',
      fullName: entity.fullName ?? '',
      dob: entity.dob ?? '',
      gender: entity.gender ?? '',
      nationality: entity.nationality ?? 'Việt Nam',
      placeOfOrigin: entity.placeOfOrigin ?? '',
      residentialAddress: entity.residentialAddress ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'id_number': idNumber,
      'full_name': fullName,
      'dob': dob,
      'gender': gender,
      'nationality': nationality,
      'place_of_origin': placeOfOrigin,
      'residential_address': residentialAddress,
    };
  }
}
