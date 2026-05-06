class AuctionDepositModel {
  final String id;
  final String auctionRoomId;
  final String productId;
  final String productName;
  final String userId;
  final num requiredAmount;
  final String transferContent;
  final String status;
  final String? adminNote;
  final String? userNote;
  final DateTime? paymentSubmittedAt;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuctionDepositModel({
    required this.id,
    required this.auctionRoomId,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.requiredAmount,
    required this.transferContent,
    required this.status,
    this.adminNote,
    this.userNote,
    this.paymentSubmittedAt,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AuctionDepositModel.fromJson(Map<String, dynamic> json) {
    return AuctionDepositModel(
      id: json['id']?.toString() ?? '',
      auctionRoomId: json['auctionRoomId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: _parseProductName(json),
      userId: json['userId']?.toString() ?? '',
      requiredAmount: json['requiredAmount'] is num
          ? json['requiredAmount'] as num
          : num.tryParse('${json['requiredAmount']}') ?? 0,
      transferContent: json['transferContent']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      adminNote: json['adminNote']?.toString(),
      userNote: json['userNote']?.toString(),
      paymentSubmittedAt: _parseDateTime(json['paymentSubmittedAt']),
      approvedAt: _parseDateTime(json['approvedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String _parseProductName(Map<String, dynamic> json) {
    final directName = json['productName']?.toString().trim() ?? '';
    if (directName.isNotEmpty) return directName;

    final product = json['product'];
    if (product is Map<String, dynamic>) {
      return product['name']?.toString().trim() ?? '';
    }

    return '';
  }
}
