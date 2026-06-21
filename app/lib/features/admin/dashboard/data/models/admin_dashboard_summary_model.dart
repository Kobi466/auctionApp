class AdminDashboardSummaryModel {
  final int totalUsers;
  final int totalProducts;
  final int totalAuctionRooms;
  final int totalPendingKyc;
  final int totalVerifiedKyc;
  final int totalRejectedKyc;
  final num totalWinningAmount;
  final num totalNetWinningAmount;
  final num totalOriginalCost;
  final num totalExpectedRevenue;
  final num totalConfirmedRevenue;
  final num totalPendingReceivable;
  final num totalHeldDeposit;
  final num totalForfeitedDeposit;
  final num totalRefundedDeposit;
  final num totalSettledDeposit;
  final num estimatedNetProfit;
  final List<AdminFinanceRankingItemModel> financeRankings;

  const AdminDashboardSummaryModel({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalAuctionRooms,
    required this.totalPendingKyc,
    required this.totalVerifiedKyc,
    required this.totalRejectedKyc,
    required this.totalWinningAmount,
    required this.totalNetWinningAmount,
    required this.totalOriginalCost,
    required this.totalExpectedRevenue,
    required this.totalConfirmedRevenue,
    required this.totalPendingReceivable,
    required this.totalHeldDeposit,
    required this.totalForfeitedDeposit,
    required this.totalRefundedDeposit,
    required this.totalSettledDeposit,
    required this.estimatedNetProfit,
    required this.financeRankings,
  });

  factory AdminDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummaryModel(
      totalUsers: _readInt(json['totalUsers']),
      totalProducts: _readInt(json['totalProducts']),
      totalAuctionRooms: _readInt(json['totalAuctionRooms']),
      totalPendingKyc: _readInt(json['totalPendingKyc']),
      totalVerifiedKyc: _readInt(json['totalVerifiedKyc']),
      totalRejectedKyc: _readInt(json['totalRejectedKyc']),
      totalWinningAmount: _readNum(json['totalWinningAmount']),
      totalNetWinningAmount: _readNum(json['totalNetWinningAmount']),
      totalOriginalCost: _readNum(json['totalOriginalCost']),
      totalExpectedRevenue: _readNum(json['totalExpectedRevenue']),
      totalConfirmedRevenue: _readNum(json['totalConfirmedRevenue']),
      totalPendingReceivable: _readNum(json['totalPendingReceivable']),
      totalHeldDeposit: _readNum(json['totalHeldDeposit']),
      totalForfeitedDeposit: _readNum(json['totalForfeitedDeposit']),
      totalRefundedDeposit: _readNum(json['totalRefundedDeposit']),
      totalSettledDeposit: _readNum(json['totalSettledDeposit']),
      estimatedNetProfit: _readNum(json['estimatedNetProfit']),
      financeRankings:
          (json['financeRankings'] as List<dynamic>? ?? const [])
              .map(
                (item) => AdminFinanceRankingItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
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

  static num _readNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminFinanceRankingItemModel {
  final String roomId;
  final String productName;
  final String winnerName;
  final num winningAmount;
  final num netWinningAmount;
  final num originalCost;
  final num estimatedProfit;
  final num remainingPayment;
  final num depositAmount;
  final String? depositStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime? endTime;

  const AdminFinanceRankingItemModel({
    required this.roomId,
    required this.productName,
    required this.winnerName,
    required this.winningAmount,
    required this.netWinningAmount,
    required this.originalCost,
    required this.estimatedProfit,
    required this.remainingPayment,
    required this.depositAmount,
    this.depositStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.endTime,
  });

  factory AdminFinanceRankingItemModel.fromJson(Map<String, dynamic> json) {
    return AdminFinanceRankingItemModel(
      roomId: json['roomId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      winnerName: json['winnerName']?.toString() ?? '',
      winningAmount: AdminDashboardSummaryModel._readNum(
        json['winningAmount'],
      ),
      netWinningAmount: AdminDashboardSummaryModel._readNum(
        json['netWinningAmount'],
      ),
      originalCost: AdminDashboardSummaryModel._readNum(json['originalCost']),
      estimatedProfit: AdminDashboardSummaryModel._readNum(
        json['estimatedProfit'],
      ),
      remainingPayment: AdminDashboardSummaryModel._readNum(
        json['remainingPayment'],
      ),
      depositAmount: AdminDashboardSummaryModel._readNum(
        json['depositAmount'],
      ),
      depositStatus: json['depositStatus']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? ''),
    );
  }
}
