import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'ble_constants.dart';

@lazySingleton
class BleChannel {
  static const _method = MethodChannel('com.neptune.app/ble');
  static const _event = EventChannel('com.neptune.app/ble/events');

  late final Stream<Map<String, dynamic>> eventStream = _event
      .receiveBroadcastStream()
      .map((e) => Map<String, dynamic>.from(e as Map));

  Future<void> startServer() => _method.invokeMethod('startServer', {
    'serviceUuid': neptuneServiceUuid,
    'writeCharUuid': neptuneWriteCharUuid,
    'notifyCharUuid': neptuneNotifyCharUuid,
  });

  Future<void> startAdvertising(List<int> serviceData) => _method.invokeMethod(
    'startAdvertising',
    {'serviceUuid': neptuneServiceUuid, 'serviceData': serviceData},
  );

  Future<void> stopAdvertising() => _method.invokeMethod('stopAdvertising');

  Future<void> stopServer() => _method.invokeMethod('stopServer');

  Future<void> startScan() => _method.invokeMethod('startScan', {
    'serviceUuid': neptuneServiceUuid,
    'timeoutMs': bleScanTimeout.inMilliseconds,
  });

  Future<void> stopScan() => _method.invokeMethod('stopScan');

  Future<void> connect(String deviceId) =>
      _method.invokeMethod('connect', {'deviceId': deviceId});

  Future<int> requestMtu(String deviceId, int mtu) async {
    final result = await _method.invokeMethod<int>('requestMtu', {
      'deviceId': deviceId,
      'mtu': mtu,
    });
    return result ?? mtu;
  }

  Future<void> writeChar(String deviceId, List<int> data) =>
      _method.invokeMethod('writeChar', {
        'deviceId': deviceId,
        'serviceUuid': neptuneServiceUuid,
        'charUuid': neptuneWriteCharUuid,
        'data': data,
      });

  Future<void> disconnect(String deviceId) =>
      _method.invokeMethod('disconnect', {'deviceId': deviceId});
}
