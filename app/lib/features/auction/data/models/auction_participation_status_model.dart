import '../../../home/data/models/product_model.dart';
import 'auction_deposit_model.dart';
import 'auction_payment_config_model.dart';

class AuctionParticipationStatusModel {
  final bool kycVerified;
  final ProductModel? product;
  final String auctionRules;
  final bool agreedToRules;
  final AuctionDepositModel? deposit;
  final AuctionPaymentConfigModel? paymentConfig;
  final bool roomAccessGranted;

  const AuctionParticipationStatusModel({
    required this.kycVerified,
    required this.auctionRules,
    required this.agreedToRules,
    required this.roomAccessGranted,
    this.product,
    this.deposit,
    this.paymentConfig,
  });

  factory AuctionParticipationStatusModel.fromJson(Map<String, dynamic> json) {
    return AuctionParticipationStatusModel(
      kycVerified: json['kycVerified'] == true,
      product: json['product'] is Map<String, dynamic>
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      auctionRules: json['auctionRules']?.toString() ?? '',
      agreedToRules: json['agreedToRules'] == true,
      deposit: json['deposit'] is Map<String, dynamic>
          ? AuctionDepositModel.fromJson(json['deposit'] as Map<String, dynamic>)
          : null,
      paymentConfig: json['paymentConfig'] is Map<String, dynamic>
          ? AuctionPaymentConfigModel.fromJson(
              json['paymentConfig'] as Map<String, dynamic>,
            )
          : null,
      roomAccessGranted: json['roomAccessGranted'] == true,
    );
  }
}
