import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/app_module.dart';
import 'core/di/injection.dart';
import 'core/storage/encrypted_db.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _resolveDevHost();
  await configureDependencies();
  await EncryptedDb.instance.open();
  runApp(const App());
}

Future<void> _resolveDevHost() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    setDevHost(info.isPhysicalDevice ? 'localhost' : '10.0.2.2');
  }
}
