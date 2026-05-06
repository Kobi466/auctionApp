class AuctionPaymentConfigModel {
  final int? id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String qrImageUrl;
  final String? branchName;
  final String? transferNotePrefix;
  final bool active;

  const AuctionPaymentConfigModel({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.qrImageUrl,
    required this.active,
    this.id,
    this.branchName,
    this.transferNotePrefix,
  });

  factory AuctionPaymentConfigModel.fromJson(Map<String, dynamic> json) {
    return AuctionPaymentConfigModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountHolderName: json['accountHolderName']?.toString() ?? '',
      qrImageUrl: json['qrImageUrl']?.toString() ?? '',
      branchName: json['branchName']?.toString(),
      transferNotePrefix: json['transferNotePrefix']?.toString(),
      active: json['active'] == true,
    );
  }
}
