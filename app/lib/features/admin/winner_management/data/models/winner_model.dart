import '../../domain/entities/winner_entity.dart';

class WinnerModel extends WinnerEntity {
  const WinnerModel({
    required super.id,
    required super.productName,
    required super.winnerName,
    required super.statusLabel,
    required super.subStatusLabel,
    required super.price,
    required super.winningTime,
    required super.status,
    super.imageUrl,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    return WinnerModel(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      winnerName: json['winnerName']?.toString() ?? '',
      statusLabel: json['statusLabel']?.toString() ?? '',
      subStatusLabel: json['subStatusLabel']?.toString() ?? '',
      price: json['price'] ?? 0,
      winningTime: DateTime.tryParse(json['winningTime']?.toString() ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl']?.toString(),
      status: _parseStatus(statusStr),
    );
  }

  static WinnerStatus _parseStatus(String status) {
    switch (status) {
      case 'won':
        return WinnerStatus.won;
      case 'paid':
        return WinnerStatus.paid;
      case 'shipping':
        return WinnerStatus.shipping;
      case 'completed':
        return WinnerStatus.completed;
      case 'preparing':
        return WinnerStatus.preparing;
      default:
        return WinnerStatus.won;
    }
  }
}
