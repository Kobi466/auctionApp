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
      userName: json['userName']?.toString() ?? 'Nguoi dung',
      userEmail: json['userEmail']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString(),
    );
  }
}
