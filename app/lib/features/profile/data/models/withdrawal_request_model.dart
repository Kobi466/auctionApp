class WithdrawalRequestModel {
  final String id;
  final String userId;
  final String username;
  final String userEmail;
  final String userFullName;
  final num amount;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? branchName;
  final String? userNote;
  final String? adminNote;
  final String status;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WithdrawalRequestModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.userFullName,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.status,
    this.branchName,
    this.userNote,
    this.adminNote,
    this.requestedAt,
    this.reviewedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse('${json['amount']}') ?? 0,
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountHolderName: json['accountHolderName']?.toString() ?? '',
      branchName: json['branchName']?.toString(),
      userNote: json['userNote']?.toString(),
      adminNote: json['adminNote']?.toString(),
      status: json['status']?.toString() ?? '',
      requestedAt: _parseDateTime(json['requestedAt']),
      reviewedAt: _parseDateTime(json['reviewedAt']),
      completedAt: _parseDateTime(json['completedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
