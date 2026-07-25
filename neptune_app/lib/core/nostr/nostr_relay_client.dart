import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'nostr_event.dart';

enum RelayClientState { disconnected, connecting, connected }

class NostrRelayClient {
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  RelayClientState _state = RelayClientState.disconnected;
  Future<void>? _connectFuture;

  final _eventController = StreamController<NostrEvent>.broadcast();
  final _eoseController = StreamController<String>.broadcast();
  final _noticeController = StreamController<String>.broadcast();

  Stream<NostrEvent> get events => _eventController.stream;
  Stream<String> get eoseStream => _eoseController.stream;
  Stream<String> get notices => _noticeController.stream;

  RelayClientState get state => _state;

  NostrRelayClient({required this.url});

  Future<void> connect() {
    if (_state == RelayClientState.connected) return Future.value();
    if (_state == RelayClientState.connecting) return _connectFuture!;
    _state = RelayClientState.connecting;
    _connectFuture = _doConnect();
    return _connectFuture!;
  }

  Future<void> _doConnect() async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    await _channel!.ready;
    _state = RelayClientState.connected;
    _connectFuture = null;

    _sub = _channel!.stream.listen(
      _onMessage,
      onError: (_) => _onDisconnected(),
      onDone: _onDisconnected,
    );
  }

  void _onDisconnected() {
    _connectFuture = null;
    _state = RelayClientState.disconnected;
  }

  void sendEvent(NostrEvent event) {
    _send(jsonEncode(['EVENT', event.toJson()]));
  }

  void subscribe(String subId, List<Map<String, dynamic>> filters) {
    _send(jsonEncode(['REQ', subId, ...filters]));
  }

  void unsubscribe(String subId) {
    _send(jsonEncode(['CLOSE', subId]));
  }

  Future<void> disconnect() async {
    _connectFuture = null;
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _state = RelayClientState.disconnected;
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _eoseController.close();
    _noticeController.close();
  }

  void _send(String message) {
    if (_state == RelayClientState.connected) {
      _channel?.sink.add(message);
    }
  }

  void _onMessage(dynamic raw) {
    final msg = jsonDecode(raw as String) as List<dynamic>;
    if (msg.isEmpty) return;

    switch (msg[0] as String) {
      case 'EVENT':
        if (msg.length >= 3) {
          final event = NostrEvent.fromJson(msg[2] as Map<String, dynamic>);
          _eventController.add(event);
        }
      case 'OK':
        final accepted = msg.length >= 3 ? msg[2] as bool : false;
        final reason = msg.length >= 4 ? msg[3] as String : '';
        debugPrint(
          '[Neptune] relay OK: id=${(msg[1] as String).substring(0, 8)}... accepted=$accepted reason=$reason',
        );
      case 'EOSE':
        if (msg.length >= 2) _eoseController.add(msg[1] as String);
      case 'NOTICE':
        if (msg.length >= 2) {
          debugPrint('[Neptune] relay NOTICE: ${msg[1]}');
          _noticeController.add(msg[1] as String);
        }
    }
  }
}
