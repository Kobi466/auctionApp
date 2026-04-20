import 'dart:io';

class KycDataEntity {
  final String? idNumber;
  final String? fullName;
  final String? dob;
  final String? gender;
  final String? nationality;
  final String? placeOfOrigin;
  final String? residentialAddress;
  
  final File? idFrontImage;
  final File? idBackImage;
  final File? faceImage;

  KycDataEntity({
    this.idNumber,
    this.fullName,
    this.dob,
    this.gender,
    this.nationality,
    this.placeOfOrigin,
    this.residentialAddress,
    this.idFrontImage,
    this.idBackImage,
    this.faceImage,
  });

  KycDataEntity copyWith({
    String? idNumber,
    String? fullName,
    String? dob,
    String? gender,
    String? nationality,
    String? placeOfOrigin,
    String? residentialAddress,
    File? idFrontImage,
    File? idBackImage,
    File? faceImage,
  }) {
    return KycDataEntity(
      idNumber: idNumber ?? this.idNumber,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      placeOfOrigin: placeOfOrigin ?? this.placeOfOrigin,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      idFrontImage: idFrontImage ?? this.idFrontImage,
      idBackImage: idBackImage ?? this.idBackImage,
      faceImage: faceImage ?? this.faceImage,
    );
  }
}
