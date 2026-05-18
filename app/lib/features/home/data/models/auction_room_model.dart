class AuctionRoomModel {
  final String id;
  final String productId;
  final String roomCode;
  final String roomPassword;
  final num minimumBid;
  final num depositAmount;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;
  final int? currentWinnerRank;
  final String? winnerPaymentStatus;
  final String? winnerPaymentReceiptUrl;
  final String? winnerPaymentUserNote;
  final String? winnerPaymentAdminNote;
  final DateTime? winnerPaymentSubmittedAt;
  final DateTime? winnerPaymentConfirmedAt;

  const AuctionRoomModel({
    required this.id,
    required this.productId,
    required this.roomCode,
    required this.roomPassword,
    required this.minimumBid,
    required this.depositAmount,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.currentWinnerRank,
    this.winnerPaymentStatus,
    this.winnerPaymentReceiptUrl,
    this.winnerPaymentUserNote,
    this.winnerPaymentAdminNote,
    this.winnerPaymentSubmittedAt,
    this.winnerPaymentConfirmedAt,
  });

  factory AuctionRoomModel.fromJson(Map<String, dynamic> json) {
    return AuctionRoomModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      roomCode: json['roomCode']?.toString() ?? '',
      roomPassword: json['roomPassword']?.toString() ?? '',
      minimumBid: json['minimumBid'] ?? 0,
      depositAmount: json['depositAmount'] ?? 0,
      startTime: _parseDateTime(json['startTime']),
      endTime: _parseDateTime(json['endTime']),
      status: json['status']?.toString() ?? '',
      currentWinnerRank: _parseInt(json['currentWinnerRank']),
      winnerPaymentStatus: json['winnerPaymentStatus']?.toString(),
      winnerPaymentReceiptUrl: json['winnerPaymentReceiptUrl']?.toString(),
      winnerPaymentUserNote: json['winnerPaymentUserNote']?.toString(),
      winnerPaymentAdminNote: json['winnerPaymentAdminNote']?.toString(),
      winnerPaymentSubmittedAt: _parseDateTime(
        json['winnerPaymentSubmittedAt'],
      ),
      winnerPaymentConfirmedAt: _parseDateTime(
        json['winnerPaymentConfirmedAt'],
      ),
    );
  }

  AuctionRoomModel copyWith({
    String? id,
    String? productId,
    String? roomCode,
    String? roomPassword,
    num? minimumBid,
    num? depositAmount,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? currentWinnerRank,
    String? winnerPaymentStatus,
    String? winnerPaymentReceiptUrl,
    String? winnerPaymentUserNote,
    String? winnerPaymentAdminNote,
    DateTime? winnerPaymentSubmittedAt,
    DateTime? winnerPaymentConfirmedAt,
  }) {
    return AuctionRoomModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      roomCode: roomCode ?? this.roomCode,
      roomPassword: roomPassword ?? this.roomPassword,
      minimumBid: minimumBid ?? this.minimumBid,
      depositAmount: depositAmount ?? this.depositAmount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      currentWinnerRank: currentWinnerRank ?? this.currentWinnerRank,
      winnerPaymentStatus: winnerPaymentStatus ?? this.winnerPaymentStatus,
      winnerPaymentReceiptUrl:
          winnerPaymentReceiptUrl ?? this.winnerPaymentReceiptUrl,
      winnerPaymentUserNote:
          winnerPaymentUserNote ?? this.winnerPaymentUserNote,
      winnerPaymentAdminNote:
          winnerPaymentAdminNote ?? this.winnerPaymentAdminNote,
      winnerPaymentSubmittedAt:
          winnerPaymentSubmittedAt ?? this.winnerPaymentSubmittedAt,
      winnerPaymentConfirmedAt:
          winnerPaymentConfirmedAt ?? this.winnerPaymentConfirmedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
