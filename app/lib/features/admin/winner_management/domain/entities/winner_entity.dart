enum WinnerStatus {
  won,
  paid,
  shipping,
  completed,
  preparing
}

class WinnerEntity {
  final String id;
  final String productName;
  final String winnerName;
  final String statusLabel;
  final String subStatusLabel;
  final num price;
  final DateTime winningTime;
  final String? imageUrl;
  final WinnerStatus status;

  const WinnerEntity({
    required this.id,
    required this.productName,
    required this.winnerName,
    required this.statusLabel,
    required this.subStatusLabel,
    required this.price,
    required this.winningTime,
    required this.status,
    this.imageUrl,
  });
}
