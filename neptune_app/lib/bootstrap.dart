import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/app_module.dart';
import 'core/di/injection.dart';
import 'core/node/inbound_server.dart';
import 'core/storage/encrypted_db.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _resolveDevHost();
  await configureDependencies();
  await EncryptedDb.instance.open();
  await _startInboundServer();
  runApp(const App());
}

Future<void> _startInboundServer() async {
  try {
    final server = getIt<InboundServer>();
    await server.start();
    debugPrint('[Neptune] LAN inbound server started on port ${server.port}');
  } catch (e) {
    debugPrint('[Neptune] LAN inbound server failed to start: $e');
  }
}

Future<void> _resolveDevHost() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    setDevHost(info.isPhysicalDevice ? 'localhost' : '10.0.2.2');
  }
}
