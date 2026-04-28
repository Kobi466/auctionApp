enum KycStatus { pending, verified, rejected }

class KycRequestEntity {
  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String idNumber;
  final String dob;
  final String address;
  final String idFrontUrl;
  final String idBackUrl;
  final String faceImageUrl;
  final KycStatus status;
  final String? rejectedReason;
  final DateTime updatedAt;

  KycRequestEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.idNumber,
    required this.dob,
    required this.address,
    required this.idFrontUrl,
    required this.idBackUrl,
    required this.faceImageUrl,
    required this.status,
    this.rejectedReason,
    required this.updatedAt,
  });
}
