class AdminDashboardSummaryModel {
  final int totalUsers;
  final int totalProducts;
  final int totalAuctionRooms;
  final int totalPendingKyc;
  final int totalVerifiedKyc;
  final int totalRejectedKyc;

  const AdminDashboardSummaryModel({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalAuctionRooms,
    required this.totalPendingKyc,
    required this.totalVerifiedKyc,
    required this.totalRejectedKyc,
  });

  factory AdminDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummaryModel(
      totalUsers: _readInt(json['totalUsers']),
      totalProducts: _readInt(json['totalProducts']),
      totalAuctionRooms: _readInt(json['totalAuctionRooms']),
      totalPendingKyc: _readInt(json['totalPendingKyc']),
      totalVerifiedKyc: _readInt(json['totalVerifiedKyc']),
      totalRejectedKyc: _readInt(json['totalRejectedKyc']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
