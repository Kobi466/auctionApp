import '../../../../core/utils/privacy_masker.dart';

class AuctionParticipantModel {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;

  const AuctionParticipantModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
  });

  factory AuctionParticipantModel.fromJson(Map<String, dynamic> json) {
    return AuctionParticipantModel(
      userId: json['userId']?.toString() ?? '',
      userName: PrivacyMasker.displayName(json['userName']?.toString()),
      userEmail: PrivacyMasker.email(json['userEmail']?.toString()),
      userAvatar: json['userAvatar']?.toString(),
    );
  }
}
