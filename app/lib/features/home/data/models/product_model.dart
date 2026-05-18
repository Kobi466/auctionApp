import 'auction_room_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String? subTitle;
  final String brand;
  final num startingPrice;
  final String? description;
  final String? shortDescription;
  final List<String> imageUrls;
  final String? mainImageUrl;
  final String categoryId;
  final List<String> tags;
  final String? authenticity;
  final String? provenance;
  final int? rarityRank;
  final DateTime? plannedStartTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AuctionRoomModel? auctionRoom;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.startingPrice,
    required this.imageUrls,
    required this.categoryId,
    required this.tags,
    required this.status,
    this.subTitle,
    this.description,
    this.shortDescription,
    this.mainImageUrl,
    this.authenticity,
    this.provenance,
    this.rarityRank,
    this.plannedStartTime,
    this.createdAt,
    this.updatedAt,
    this.auctionRoom,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subTitle: json['subTitle']?.toString(),
      brand: json['brand']?.toString() ?? '',
      startingPrice: json['startingPrice'] is num
          ? json['startingPrice'] as num
          : num.tryParse('${json['startingPrice']}') ?? 0,
      description: json['description']?.toString(),
      shortDescription: json['shortDescription']?.toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      mainImageUrl: json['mainImageUrl']?.toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      authenticity: json['authenticity']?.toString(),
      provenance: json['provenance']?.toString(),
      rarityRank: json['rarityRank'] as int?,
      plannedStartTime: _parseDateTime(json['plannedStartTime']),
      status: json['status']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      auctionRoom: json['auctionRoom'] is Map<String, dynamic>
          ? AuctionRoomModel.fromJson(
              json['auctionRoom'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  String get displayImage {
    if (mainImageUrl != null && mainImageUrl!.trim().isNotEmpty) {
      return mainImageUrl!.trim();
    }
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return '';
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? subTitle,
    String? brand,
    num? startingPrice,
    String? description,
    String? shortDescription,
    List<String>? imageUrls,
    String? mainImageUrl,
    String? categoryId,
    List<String>? tags,
    String? authenticity,
    String? provenance,
    int? rarityRank,
    DateTime? plannedStartTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuctionRoomModel? auctionRoom,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subTitle: subTitle ?? this.subTitle,
      brand: brand ?? this.brand,
      startingPrice: startingPrice ?? this.startingPrice,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      imageUrls: imageUrls ?? this.imageUrls,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      authenticity: authenticity ?? this.authenticity,
      provenance: provenance ?? this.provenance,
      rarityRank: rarityRank ?? this.rarityRank,
      plannedStartTime: plannedStartTime ?? this.plannedStartTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      auctionRoom: auctionRoom ?? this.auctionRoom,
    );
  }

  DateTime? get effectiveStartTime =>
      auctionRoom?.startTime ?? plannedStartTime;

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }
}
