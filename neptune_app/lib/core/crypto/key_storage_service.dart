import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorageService {
  KeyStorageService._();

  static final KeyStorageService instance = KeyStorageService._();

  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _dbKeyStorageKey = 'neptune_db_key';
  static const _identityPrivKeyStorageKey = 'neptune_identity_priv_key';
  static const _authTokenStorageKey = 'neptune_auth_token';

  Future<String> getOrCreateDbKey() async {
    final existing = await _storage.read(key: _dbKeyStorageKey);
    if (existing != null) return existing;
    final key = _randomHex(32);
    await _storage.write(key: _dbKeyStorageKey, value: key);
    return key;
  }

  Future<String?> getIdentityPrivKey() async {
    return _storage.read(key: _identityPrivKeyStorageKey);
  }

  Future<void> saveIdentityPrivKey(String privKeyHex) async {
    await _storage.write(key: _identityPrivKeyStorageKey, value: privKeyHex);
  }

  Future<void> deleteIdentityPrivKey() async {
    await _storage.delete(key: _identityPrivKeyStorageKey);
  }

  Future<String?> getAuthToken() async {
    return _storage.read(key: _authTokenStorageKey);
  }

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenStorageKey, value: token);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenStorageKey);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  String _randomHex(int byteCount) {
    final rng = Random.secure();
    final bytes = Uint8List(byteCount);
    for (var i = 0; i < byteCount; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
