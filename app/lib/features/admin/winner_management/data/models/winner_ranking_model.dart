class WinnerRankingModel {
  final int rank;
  final String userId;
  final String userName;
  final String userEmail;
  final num amount;
  final DateTime bidTime;
  final bool winner;
  final String? depositStatus;
  final bool activeOffer;
  final String? winnerPaymentStatus;
  final String? winnerPaymentMethod;
  final String? winnerShippingAddress;
  final String? winnerPaymentReceiptUrl;
  final String? winnerPaymentUserNote;
  final String? winnerPaymentAdminNote;
  final int? winnerPaymentRejectedCount;
  final DateTime? winnerPaymentSubmittedAt;

  const WinnerRankingModel({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.bidTime,
    required this.winner,
    this.depositStatus,
    this.activeOffer = false,
    this.winnerPaymentStatus,
    this.winnerPaymentMethod,
    this.winnerShippingAddress,
    this.winnerPaymentReceiptUrl,
    this.winnerPaymentUserNote,
    this.winnerPaymentAdminNote,
    this.winnerPaymentRejectedCount,
    this.winnerPaymentSubmittedAt,
  });

  factory WinnerRankingModel.fromJson(Map<String, dynamic> json) {
    return WinnerRankingModel(
      rank: int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      amount: json['amount'] as num? ?? 0,
      bidTime:
          DateTime.tryParse(json['bidTime']?.toString() ?? '') ??
          DateTime.now(),
      winner: json['winner'] == true,
      depositStatus: json['depositStatus']?.toString(),
      activeOffer: json['activeOffer'] == true,
      winnerPaymentStatus: json['winnerPaymentStatus']?.toString(),
      winnerPaymentMethod: json['winnerPaymentMethod']?.toString(),
      winnerShippingAddress: json['winnerShippingAddress']?.toString(),
      winnerPaymentReceiptUrl: json['winnerPaymentReceiptUrl']?.toString(),
      winnerPaymentUserNote: json['winnerPaymentUserNote']?.toString(),
      winnerPaymentAdminNote: json['winnerPaymentAdminNote']?.toString(),
      winnerPaymentRejectedCount: int.tryParse(
        json['winnerPaymentRejectedCount']?.toString() ?? '',
      ),
      winnerPaymentSubmittedAt: DateTime.tryParse(
        json['winnerPaymentSubmittedAt']?.toString() ?? '',
      ),
    );
  }
}
