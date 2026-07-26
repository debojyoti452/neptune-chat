import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../ble/ble_service.dart';
import '../crypto/key_storage_service.dart';
import '../discovery/peer_discovery_service.dart';
import '../nostr/nostr_event.dart';
import '../nostr/nostr_relay_client.dart';

@lazySingleton
class TransportRouter {
  TransportRouter({
    required this._internetRelay,
    required this._discovery,
    required this._keyStorage,
    required this._ble,
  });

  final NostrRelayClient _internetRelay;
  final PeerDiscoveryService _discovery;
  final KeyStorageService _keyStorage;
  final BleService _ble;

  Future<void> send(NostrEvent event, {String? toPubkey}) async {
    if (toPubkey != null) {
      final bleSent = await _ble.send(event, toPubkey: toPubkey);
      if (bleSent) return;

      final token = await _keyStorage.getAuthToken();
      if (token != null) {
        final hint = await _discovery.fetchLanHint(toPubkey, token);
        if (hint != null) {
          try {
            await _sendViaLan(event, hint);
            debugPrint('[Neptune] LAN: sent event to ${hint.ip}:${hint.port}');
            return;
          } catch (e) {
            debugPrint(
              '[Neptune] LAN: send failed ($e), falling back to internet',
            );
          }
        }
      }
    }
    _internetRelay.sendEvent(event);
  }

  Future<void> _sendViaLan(NostrEvent event, PeerHint hint) async {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://${hint.ip}:${hint.port}'),
    );
    try {
      await channel.ready;
      channel.sink.add(jsonEncode(['EVENT', event.toJson()]));
      await channel.sink.close();
    } catch (e) {
      channel.sink.close().ignore();
      rethrow;
    }
  }
}
