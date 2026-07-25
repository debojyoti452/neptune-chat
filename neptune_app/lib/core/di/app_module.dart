import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../crypto/key_storage_service.dart';
import '../nostr/nostr_relay_client.dart';
import '../storage/encrypted_db.dart';

const _relayUrlOverride = String.fromEnvironment('NEPTUNE_RELAY_URL');
const _apiBaseUrlOverride = String.fromEnvironment('NEPTUNE_API_URL');

String _resolvedHost = 'localhost';

void setDevHost(String host) => _resolvedHost = host;

String get _relayUrl {
  if (_relayUrlOverride.isNotEmpty) return _relayUrlOverride;
  return 'ws://$_resolvedHost:4000/nostr';
}

String get _apiBaseUrl {
  if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
  return 'http://$_resolvedHost:4000';
}

@module
abstract class AppModule {
  @singleton
  EncryptedDb get encryptedDb => EncryptedDb.instance;

  @singleton
  KeyStorageService get keyStorageService => KeyStorageService.instance;

  @singleton
  NostrRelayClient get nostrRelayClient => NostrRelayClient(url: _relayUrl);

  @singleton
  http.Client get httpClient => http.Client();

  @Named('apiBaseUrl')
  String get apiBaseUrl => _apiBaseUrl;
}
