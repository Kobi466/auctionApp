class AuctionRoomAccessModel {
  final String roomId;
  final String roomCode;
  final String roomPassword;

  const AuctionRoomAccessModel({
    required this.roomId,
    required this.roomCode,
    required this.roomPassword,
  });

  factory AuctionRoomAccessModel.fromJson(Map<String, dynamic> json) {
    return AuctionRoomAccessModel(
      roomId: json['roomId']?.toString() ?? '',
      roomCode: json['roomCode']?.toString() ?? '',
      roomPassword: json['roomPassword']?.toString() ?? '',
    );
  }
}
