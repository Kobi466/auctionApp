import '../../domain/entities/kyc_data_entity.dart';

class KycResponseModel {
  final String id;
  final String userId;
  final String idNumber;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String placeOfOrigin;
  final String placeOfResidence;
  final String selfie;
  final String frontSide;
  final String backSide;
  final String status;
  final String? rejectedReason;

  const KycResponseModel({
    required this.id,
    required this.userId,
    required this.idNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.placeOfOrigin,
    required this.placeOfResidence,
    required this.selfie,
    required this.frontSide,
    required this.backSide,
    required this.status,
    this.rejectedReason,
  });

  factory KycResponseModel.fromJson(Map<String, dynamic> json) {
    return KycResponseModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      idNumber: json['idNumber']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      placeOfOrigin: json['placeOfOrigin']?.toString() ?? '',
      placeOfResidence: json['placeOfResidence']?.toString() ?? '',
      selfie: json['selfie']?.toString() ?? '',
      frontSide: json['frontSide']?.toString() ?? '',
      backSide: json['backSide']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      rejectedReason: json['rejectedReason']?.toString(),
    );
  }

  KycDataEntity toEntity() {
    return KycDataEntity(
      idNumber: idNumber,
      fullName: fullName,
      dob: dateOfBirth,
      gender: gender,
      nationality: nationality,
      placeOfOrigin: placeOfOrigin,
      residentialAddress: placeOfResidence,
    );
  }
}
