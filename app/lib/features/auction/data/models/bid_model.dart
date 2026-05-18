import '../../../../core/utils/privacy_masker.dart';

class BidModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final num amount;
  final DateTime createdAt;
  final bool isLeading;

  const BidModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.amount,
    required this.createdAt,
    this.isLeading = false,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: PrivacyMasker.displayName(json['userName']?.toString()),
      userAvatar: json['userAvatar']?.toString(),
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse('${json['amount']}') ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isLeading: json['isLeading'] == true || json['leading'] == true,
    );
  }
}
