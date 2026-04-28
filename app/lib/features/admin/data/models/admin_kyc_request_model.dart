import '../../kyc/domain/entities/kyc_request_entity.dart';

class AdminKycRequestModel {
  final String id;
  final String userId;
  final String email;
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
  final String updatedAt;

  const AdminKycRequestModel({
    required this.id,
    required this.userId,
    required this.email,
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
    required this.updatedAt,
    this.rejectedReason,
  });

  factory AdminKycRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminKycRequestModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
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
      status: json['status']?.toString() ?? 'PENDING',
      updatedAt: json['updatedAt']?.toString() ?? '',
      rejectedReason: json['rejectedReason']?.toString(),
    );
  }

  KycRequestEntity toEntity() {
    return KycRequestEntity(
      id: id,
      fullName: fullName,
      email: email,
      avatarUrl: _buildAvatarUrl(email),
      idNumber: idNumber,
      dob: _formatDate(dateOfBirth),
      address: placeOfResidence,
      idFrontUrl: frontSide,
      idBackUrl: backSide,
      faceImageUrl: selfie,
      status: _mapStatus(status),
      rejectedReason: rejectedReason,
      updatedAt: DateTime.tryParse(updatedAt)?.toLocal() ?? DateTime.now(),
    );
  }

  static KycStatus _mapStatus(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'VERIFIED':
        return KycStatus.verified;
      case 'REJECTED':
        return KycStatus.rejected;
      default:
        return KycStatus.pending;
    }
  }

  static String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  static String _buildAvatarUrl(String email) {
    final seed = email.isEmpty ? 'admin-kyc-user' : email;
    return 'https://api.dicebear.com/7.x/initials/png?seed=$seed';
  }
}
