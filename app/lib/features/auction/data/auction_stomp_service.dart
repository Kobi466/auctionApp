import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/network/api_client.dart';
import 'models/bid_model.dart';

class AuctionUpdateModel {
  final num currentPrice;
  final DateTime? endTime;

  const AuctionUpdateModel({required this.currentPrice, this.endTime});

  factory AuctionUpdateModel.fromJson(Map<String, dynamic> json) {
    return AuctionUpdateModel(
      currentPrice: json['currentPrice'] is num
          ? json['currentPrice'] as num
          : num.tryParse('${json['currentPrice']}') ?? 0,
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? ''),
    );
  }
}

class AuctionNotificationModel {
  final String type;
  final String message;
  final String? auctionId;

  const AuctionNotificationModel({
    required this.type,
    required this.message,
    this.auctionId,
  });

  factory AuctionNotificationModel.fromJson(Map<String, dynamic> json) {
    return AuctionNotificationModel(
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      auctionId: json['auctionId']?.toString(),
    );
  }
}

class AuctionStompService {
  StompClient? _client;
  StompUnsubscribe? _unsubscribeBid;
  StompUnsubscribe? _unsubscribeAuction;
  StompUnsubscribe? _unsubscribeNotifications;

  bool get isConnected => _client?.connected ?? false;

  void connect({
    required String accessToken,
    required String roomId,
    required void Function(BidModel bid) onBid,
    required void Function(AuctionUpdateModel update) onAuctionUpdate,
    required void Function(String message) onError,
    void Function(AuctionNotificationModel notification)? onNotification,
    void Function()? onConnected,
  }) {
    disconnect();

    final headers = {'Authorization': 'Bearer $accessToken'};
    _client = StompClient(
      config: StompConfig.sockJS(
        url: ApiClient().webSocketUrl,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        reconnectDelay: const Duration(seconds: 5),
        onConnect: (_) {
          onConnected?.call();
          _unsubscribeBid = _client?.subscribe(
            destination: '/topic/auction/$roomId/bids',
            callback: (frame) {
              final body = _decodeFrame(frame);
              if (body == null) return;
              onBid(
                BidModel.fromJson({
                  'id': body['id'] ?? '',
                  'userId': body['bidderId'],
                  'userName': body['bidderName'],
                  'amount': body['amount'],
                  'createdAt': body['timestamp'],
                  'leading': true,
                }),
              );
            },
          );

          _unsubscribeAuction = _client?.subscribe(
            destination: '/topic/auction/$roomId',
            callback: (frame) {
              final body = _decodeFrame(frame);
              if (body == null) return;
              onAuctionUpdate(AuctionUpdateModel.fromJson(body));
            },
          );

          _unsubscribeNotifications = _client?.subscribe(
            destination: '/user/queue/notifications',
            callback: (frame) {
              final body = _decodeFrame(frame);
              if (body == null) {
                onError('WebSocket error');
                return;
              }
              final notification = AuctionNotificationModel.fromJson(body);
              if (notification.type == 'ERROR') {
                onError(notification.message);
                return;
              }
              onNotification?.call(notification);
            },
          );
        },
        onWebSocketError: (error) => onError(error.toString()),
        onStompError: (frame) => onError(frame.body ?? 'STOMP error'),
      ),
    );

    _client?.activate();
  }

  void sendBid({required String roomId, required num amount}) {
    final client = _client;
    if (client == null || !client.connected) {
      throw Exception('Chua ket noi realtime phong dau gia');
    }

    client.send(
      destination: '/app/auction/bid',
      body: jsonEncode({'auctionId': roomId, 'amount': amount}),
      headers: {'content-type': 'application/json'},
    );
  }

  void disconnect() {
    _unsubscribeBid?.call();
    _unsubscribeAuction?.call();
    _unsubscribeNotifications?.call();
    _unsubscribeBid = null;
    _unsubscribeAuction = null;
    _unsubscribeNotifications = null;
    _client?.deactivate();
    _client = null;
  }

  Map<String, dynamic>? _decodeFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }
}
