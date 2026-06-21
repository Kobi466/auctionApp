import '../../../home/data/models/product_model.dart';
import 'auction_participant_model.dart';
import 'bid_model.dart';

class AuctionRoomSummaryModel {
  final ProductModel product;
  final num currentPrice;
  final int bidCount;
  final int watcherCount;
  final List<AuctionParticipantModel> participants;
  final List<BidModel> bids;
  final int? currentWinnerRank;
  final String? winnerPaymentStatus;
  final String? winnerPaymentMethod;
  final String? winnerShippingAddress;
  final num? winnerPaymentAmount;
  final String? winnerPaymentReceiptUrl;
  final String? winnerPaymentUserNote;
  final int? winnerPaymentRejectedCount;
  final DateTime? winnerPaymentSubmittedAt;
  final bool currentUserWinnerPaymentEligible;

  const AuctionRoomSummaryModel({
    required this.product,
    required this.currentPrice,
    required this.bidCount,
    required this.watcherCount,
    required this.participants,
    required this.bids,
    this.currentWinnerRank,
    this.winnerPaymentStatus,
    this.winnerPaymentMethod,
    this.winnerShippingAddress,
    this.winnerPaymentAmount,
    this.winnerPaymentReceiptUrl,
    this.winnerPaymentUserNote,
    this.winnerPaymentRejectedCount,
    this.winnerPaymentSubmittedAt,
    this.currentUserWinnerPaymentEligible = false,
  });

  factory AuctionRoomSummaryModel.fromJson(Map<String, dynamic> json) {
    return AuctionRoomSummaryModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      currentPrice: json['currentPrice'] is num
          ? json['currentPrice'] as num
          : num.tryParse('${json['currentPrice']}') ?? 0,
      bidCount: _readInt(json['bidCount']),
      watcherCount: _readInt(json['watcherCount']),
      participants: (json['participants'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                AuctionParticipantModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      bids: (json['bids'] as List<dynamic>? ?? const [])
          .map((item) => BidModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentWinnerRank: _readNullableInt(json['currentWinnerRank']),
      winnerPaymentStatus: json['winnerPaymentStatus']?.toString(),
      winnerPaymentMethod: json['winnerPaymentMethod']?.toString(),
      winnerShippingAddress: json['winnerShippingAddress']?.toString(),
      winnerPaymentAmount: json['winnerPaymentAmount'] is num
          ? json['winnerPaymentAmount'] as num
          : num.tryParse('${json['winnerPaymentAmount']}'),
      winnerPaymentReceiptUrl: json['winnerPaymentReceiptUrl']?.toString(),
      winnerPaymentUserNote: json['winnerPaymentUserNote']?.toString(),
      winnerPaymentRejectedCount: _readNullableInt(
        json['winnerPaymentRejectedCount'],
      ),
      winnerPaymentSubmittedAt: DateTime.tryParse(
        json['winnerPaymentSubmittedAt']?.toString() ?? '',
      ),
      currentUserWinnerPaymentEligible:
          json['currentUserWinnerPaymentEligible'] == true,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
