import 'dart:convert';
import 'dart:io';

import '../../domain/entities/kyc_data_entity.dart';

class KycRequestModel {
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

  KycRequestModel({
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
  });

  static Future<KycRequestModel> fromEntity(KycDataEntity entity) async {
    return KycRequestModel(
      idNumber: entity.idNumber?.trim() ?? '',
      fullName: entity.fullName?.trim() ?? '',
      dateOfBirth: entity.dob?.trim() ?? '',
      gender: entity.gender?.trim() ?? '',
      nationality: entity.nationality?.trim() ?? '',
      placeOfOrigin: entity.placeOfOrigin?.trim() ?? '',
      placeOfResidence: entity.residentialAddress?.trim() ?? '',
      selfie: await _encodeFile(entity.faceImage),
      frontSide: await _encodeFile(entity.idFrontImage),
      backSide: await _encodeFile(entity.idBackImage),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idNumber': idNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'placeOfOrigin': placeOfOrigin,
      'placeOfResidence': placeOfResidence,
      'selfie': selfie,
      'frontSide': frontSide,
      'backSide': backSide,
    };
  }

  static Future<String> _encodeFile(File? file) async {
    if (file == null) {
      return '';
    }

    final bytes = await file.readAsBytes();
    final encoded = base64Encode(bytes);
    final extension = file.path.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    return 'data:$mimeType;base64,$encoded';
  }
}
