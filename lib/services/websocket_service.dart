import 'dart:async';
import 'dart:convert';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<MarketData>? _controller;

  Stream<MarketData>? get stream => _controller?.stream;

  void connect() {
    _controller = StreamController<MarketData>.broadcast();
    _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
    _channel!.stream.listen((message) {
      _controller?.add(MarketData.fromJson(jsonDecode(message)['data']));
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
  }
}
