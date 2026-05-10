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

  const AuctionRoomSummaryModel({
    required this.product,
    required this.currentPrice,
    required this.bidCount,
    required this.watcherCount,
    required this.participants,
    required this.bids,
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
          .map((item) =>
              AuctionParticipantModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      bids: (json['bids'] as List<dynamic>? ?? const [])
          .map((item) => BidModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
