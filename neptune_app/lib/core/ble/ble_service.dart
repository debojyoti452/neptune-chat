import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/digests/sha256.dart';

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

  bool _isStarted = false;
  StreamSubscription<Map<String, dynamic>>? _eventSub;
  final _decoders = <String, BleMessageDecoder>{};

  Future<void> start(String myPubkey) async {
    if (_isStarted) return;
    await _channel.startServer();
    final prefix = _pubkeyHashPrefix(myPubkey);
    await _channel.startAdvertising(prefix);
    _eventSub = _channel.eventStream.listen(_handleEvent);
    _isStarted = true;
    debugPrint('[Neptune] BLE: started');
  }

  Future<void> stop() async {
    _isStarted = false;
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
    String? connectedDeviceId;
    try {
      final hashPrefix = _pubkeyHashPrefix(toPubkey);
      final deviceId = await _scanForPeer(hashPrefix);
      if (deviceId == null) return false;

      await _channel.connect(deviceId);
      connectedDeviceId = deviceId;

      final mtu = await _channel.requestMtu(deviceId, 512);

      final json = jsonEncode(event.toJson());
      final chunks = BleMessageCodec.encode(json, mtu);
      for (final chunk in chunks) {
        await _channel.writeChar(deviceId, chunk);
      }

      debugPrint('[Neptune] BLE: sent event ${event.id.substring(0, 8)}...');

      await _channel.disconnect(deviceId);
      connectedDeviceId = null;
      return true;
    } catch (e) {
      debugPrint('[Neptune] BLE: send failed ($e)');
      if (connectedDeviceId != null) {
        try {
          await _channel.disconnect(connectedDeviceId);
        } catch (_) {}
      }
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
          _channel.stopScan().ignore();
          completer.complete(evt['deviceId'] as String);
        }
      }
    });

    await _channel.startScan();

    Timer(bleScanTimeout, () {
      scanSub?.cancel();
      if (!completer.isCompleted) {
        _channel.stopScan().ignore();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  void _handleEvent(Map<String, dynamic> evt) {
    if (evt['type'] == 'disconnected') {
      _decoders.remove(evt['deviceId'] as String);
      return;
    }
    if (evt['type'] != 'writeReceived') return;
    final deviceId = evt['deviceId'] as String;
    final data = Uint8List.fromList(List<int>.from(evt['data'] as List));
    final decoder = _decoders[deviceId] ??= BleMessageDecoder();
    try {
      final json = decoder.addChunk(data);
      if (json != null) {
        final event = NostrEvent.fromJson(
          Map<String, dynamic>.from(jsonDecode(json) as Map),
        );
        onEvent?.call(event);
      }
    } on FormatException catch (e) {
      debugPrint('[Neptune] BLE: dropping oversized frame from $deviceId ($e)');
      _decoders.remove(deviceId);
    } catch (e) {
      debugPrint('[Neptune] BLE: failed to parse incoming event ($e)');
    }
  }

  Uint8List _pubkeyHashPrefix(String pubkey) {
    final bytes = Uint8List(pubkey.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(pubkey.substring(i * 2, i * 2 + 2), radix: 16);
    }
    final hash = SHA256Digest().process(bytes);
    return hash.sublist(0, blePubkeyPrefixLength);
  }

  bool _prefixMatches(Uint8List data, Uint8List prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }
}
