class AdminDepositModel {
  final String id;
  final String auctionRoomId;
  final String productId;
  final String productName;
  final String userId;
  final String username;
  final String userEmail;
  final String userFullName;
  final num requiredAmount;
  final String transferContent;
  final String status;
  final String? adminNote;
  final String? userNote;
  final DateTime? paymentSubmittedAt;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminDepositModel({
    required this.id,
    required this.auctionRoomId,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.userFullName,
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

  factory AdminDepositModel.fromJson(Map<String, dynamic> json) {
    return AdminDepositModel(
      id: json['id']?.toString() ?? '',
      auctionRoomId: json['auctionRoomId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: _stringValue(json['productName']),
      userId: json['userId']?.toString() ?? '',
      username: _stringValue(json['username']),
      userEmail: _stringValue(json['userEmail']),
      userFullName: _stringValue(json['userFullName']),
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

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
