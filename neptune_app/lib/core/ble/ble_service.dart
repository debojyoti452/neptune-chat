import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

import '../nostr/nostr_event.dart';
import 'ble_constants.dart';
import 'ble_message_codec.dart';

typedef InboundEventHandler = Future<void> Function(NostrEvent event);

@singleton
class BleService {
  InboundEventHandler? onEvent;

  String? _myPubkey;
  StreamSubscription<List<ScanResult>>? _scanSub;
  final _decoders = <DeviceIdentifier, BleMessageDecoder>{};
  final _connectedDevices = <DeviceIdentifier, BluetoothDevice>{};

  Future<void> start(String myPubkey) async {
    _myPubkey = myPubkey;
    await _startAdvertising(myPubkey);
  }

  Future<void> stop() async {
    await _stopScan();
    for (final device in _connectedDevices.values) {
      await device.disconnect();
    }
    _connectedDevices.clear();
    _decoders.clear();
    _myPubkey = null;
    try {
      await FlutterBluePlus.stopAdvertising();
    } catch (_) {}
  }

  Future<bool> send(NostrEvent event, {required String toPubkey}) async {
    try {
      final hashPrefix = _pubkeyHashPrefix(toPubkey);
      final device = await _scanForPeer(hashPrefix);
      if (device == null) return false;

      await device.connect(timeout: const Duration(seconds: 8));
      final mtu = await device.requestMtu(512);

      final services = await device.discoverServices();
      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? notifyChar;

      for (final svc in services) {
        if (svc.uuid == neptuneServiceUuid) {
          for (final char in svc.characteristics) {
            if (char.uuid == neptuneWriteCharUuid) writeChar = char;
            if (char.uuid == neptuneNotifyCharUuid) notifyChar = char;
          }
        }
      }

      if (writeChar == null) {
        await device.disconnect();
        return false;
      }

      if (notifyChar != null) {
        await notifyChar.setNotifyValue(true);
        _decoders[device.remoteId] ??= BleMessageDecoder();
        notifyChar.lastValueStream.listen((chunk) {
          _handleNotifyChunk(device.remoteId, Uint8List.fromList(chunk));
        });
      }

      final json = jsonEncode(event.toJson());
      final chunks = BleMessageCodec.encode(json, mtu);
      for (final chunk in chunks) {
        await writeChar.write(chunk, withoutResponse: true);
      }

      debugPrint('[Neptune] BLE: sent event ${event.id.substring(0, 8)}...');

      await device.disconnect();
      _connectedDevices.remove(device.remoteId);
      return true;
    } catch (e) {
      debugPrint('[Neptune] BLE: send failed ($e)');
      return false;
    }
  }

  Future<void> _startAdvertising(String pubkey) async {
    try {
      final hashPrefix = _pubkeyHashPrefix(pubkey);
      await FlutterBluePlus.startAdvertising(
        AdvertisementData(
          localName: 'Neptune',
          serviceUuids: [neptuneServiceUuid],
          serviceData: {neptuneServiceUuid: hashPrefix},
        ),
      );
      debugPrint('[Neptune] BLE: advertising started');
    } catch (e) {
      debugPrint('[Neptune] BLE: advertising failed ($e)');
    }
  }

  Future<BluetoothDevice?> _scanForPeer(Uint8List hashPrefix) async {
    final completer = Completer<BluetoothDevice?>();
    Timer? timeoutTimer;

    await FlutterBluePlus.startScan(
      withServices: [neptuneServiceUuid],
      timeout: bleScanTimeout,
    );

    timeoutTimer = Timer(bleScanTimeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final data =
            result.advertisementData.serviceData[neptuneServiceUuid];
        if (data != null && _prefixMatches(Uint8List.fromList(data), hashPrefix)) {
          timeoutTimer?.cancel();
          _scanSub?.cancel();
          if (!completer.isCompleted) {
            completer.complete(result.device);
          }
          return;
        }
      }
    });

    return completer.future;
  }

  Future<void> _stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  void _handleNotifyChunk(DeviceIdentifier id, Uint8List chunk) {
    final decoder = _decoders[id] ??= BleMessageDecoder();
    final json = decoder.addChunk(chunk);
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
