import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../nostr/nostr_event.dart';
import 'ble_channel.dart';
import 'ble_constants.dart';
import 'ble_message_codec.dart';

typedef InboundEventHandler = Future<void> Function(NostrEvent event);

@singleton
class BleService {
  BleService(this._channel);

  final BleChannel _channel;

  InboundEventHandler? onEvent;

  StreamSubscription<Map<String, dynamic>>? _eventSub;
  final _decoders = <String, BleMessageDecoder>{};

  Future<void> start(String myPubkey) async {
    await _channel.startServer();
    final prefix = _pubkeyHashPrefix(myPubkey);
    await _channel.startAdvertising(prefix);

    _eventSub = _channel.eventStream.listen(_handleEvent);
    debugPrint('[Neptune] BLE: started');
  }

  Future<void> stop() async {
    await _eventSub?.cancel();
    _eventSub = null;
    _decoders.clear();
    try {
      await _channel.stopScan();
    } catch (_) {}
    try {
      await _channel.stopAdvertising();
    } catch (_) {}
    try {
      await _channel.stopServer();
    } catch (_) {}
  }

  Future<bool> send(NostrEvent event, {required String toPubkey}) async {
    try {
      final hashPrefix = _pubkeyHashPrefix(toPubkey);
      final deviceId = await _scanForPeer(hashPrefix);
      if (deviceId == null) return false;

      await _channel.connect(deviceId);
      final mtu = await _channel.requestMtu(deviceId, 512);

      final json = jsonEncode(event.toJson());
      final chunks = BleMessageCodec.encode(json, mtu);
      for (final chunk in chunks) {
        await _channel.writeChar(deviceId, chunk);
      }

      debugPrint('[Neptune] BLE: sent event ${event.id.substring(0, 8)}...');

      await _channel.disconnect(deviceId);
      return true;
    } catch (e) {
      debugPrint('[Neptune] BLE: send failed ($e)');
      return false;
    }
  }

  Future<String?> _scanForPeer(Uint8List hashPrefix) async {
    final completer = Completer<String?>();
    StreamSubscription<Map<String, dynamic>>? scanSub;

    scanSub = _channel.eventStream.listen((evt) {
      if (evt['type'] != 'scanResult') return;
      final data = evt['serviceData'];
      if (data == null) return;
      final bytes = Uint8List.fromList(List<int>.from(data as List));
      if (_prefixMatches(bytes, hashPrefix)) {
        scanSub?.cancel();
        if (!completer.isCompleted) {
          completer.complete(evt['deviceId'] as String);
        }
      }
    });

    await _channel.startScan();

    Timer(bleScanTimeout, () {
      scanSub?.cancel();
      if (!completer.isCompleted) completer.complete(null);
    });

    return completer.future;
  }

  void _handleEvent(Map<String, dynamic> evt) {
    if (evt['type'] != 'writeReceived') return;
    final deviceId = evt['deviceId'] as String;
    final data = Uint8List.fromList(List<int>.from(evt['data'] as List));
    final decoder = _decoders[deviceId] ??= BleMessageDecoder();
    final json = decoder.addChunk(data);
    if (json != null) {
      try {
        final event = NostrEvent.fromJson(
          Map<String, dynamic>.from(jsonDecode(json) as Map),
        );
        onEvent?.call(event);
      } catch (e) {
        debugPrint('[Neptune] BLE: failed to parse incoming event ($e)');
      }
    }
  }

  Uint8List _pubkeyHashPrefix(String pubkey) {
    final hexPrefix = pubkey.substring(0, blePublickeyHashLength * 2);
    final result = Uint8List(blePublickeyHashLength);
    for (var i = 0; i < blePublickeyHashLength; i++) {
      result[i] = int.parse(hexPrefix.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  bool _prefixMatches(Uint8List data, Uint8List prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }
}
