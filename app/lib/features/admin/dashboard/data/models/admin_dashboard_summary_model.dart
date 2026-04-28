class AdminDashboardSummaryModel {
  final int totalUsers;
  final int totalPendingKyc;
  final int totalVerifiedKyc;
  final int totalRejectedKyc;

  const AdminDashboardSummaryModel({
    required this.totalUsers,
    required this.totalPendingKyc,
    required this.totalVerifiedKyc,
    required this.totalRejectedKyc,
  });

  factory AdminDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummaryModel(
      totalUsers: (json['totalUsers'] ?? 0) as int,
      totalPendingKyc: (json['totalPendingKyc'] ?? 0) as int,
      totalVerifiedKyc: (json['totalVerifiedKyc'] ?? 0) as int,
      totalRejectedKyc: (json['totalRejectedKyc'] ?? 0) as int,
    );
  }
}
