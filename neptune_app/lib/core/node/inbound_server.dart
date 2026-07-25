import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../nostr/nostr_event.dart';

typedef InboundEventHandler = Future<void> Function(NostrEvent event);

@singleton
class InboundServer {
  HttpServer? _server;
  int? _port;

  InboundEventHandler? onEvent;

  int? get port => _port;
  bool get isRunning => _server != null;

  Future<void> start() async {
    final handler = webSocketHandler(
      (WebSocketChannel ws, String? subprotocol) => _handleConnection(ws),
    );

    _server = await shelf_io.serve(
      logRequests().addHandler(handler),
      InternetAddress.anyIPv4,
      0,
    );
    _port = _server!.port;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }

  void _handleConnection(WebSocketChannel ws) {
    ws.stream.listen((raw) async {
      try {
        final msg = jsonDecode(raw as String) as List<dynamic>;
        if (msg.isEmpty || msg[0] != 'EVENT') return;
        final event = NostrEvent.fromJson(msg[2] as Map<String, dynamic>);
        await onEvent?.call(event);
      } catch (_) {}
    });
  }
}
