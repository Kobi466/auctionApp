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
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }
}
