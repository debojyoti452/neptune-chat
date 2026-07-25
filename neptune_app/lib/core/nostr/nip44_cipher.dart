import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

abstract final class Nip44Cipher {
  static const int _version = 2;
  static const String _hkdfSalt = 'nip44-v2';

  static Future<String> encrypt(
    String plaintext,
    Uint8List conversationKey,
  ) async {
    final nonce = _randomBytes(32);
    final keys = await _messageKeys(conversationKey, nonce);

    final padded = _pad(utf8.encode(plaintext));
    final ciphertext = await _chacha20Encrypt(
      keys.cipherKey,
      keys.chachaNonce,
      padded,
    );
    final mac = await _hmacSha256(
      keys.hmacKey,
      Uint8List.fromList([...nonce, ...ciphertext]),
    );

    final payload = Uint8List.fromList([
      _version,
      ...nonce,
      ...ciphertext,
      ...mac,
    ]);
    return base64.encode(payload);
  }

  static Future<String> decrypt(
    String encodedPayload,
    Uint8List conversationKey,
  ) async {
    final payload = base64.decode(encodedPayload);

    if (payload[0] != _version) {
      throw ArgumentError('Unsupported NIP-44 version: ${payload[0]}');
    }

    final nonce = payload.sublist(1, 33);
    final mac = payload.sublist(payload.length - 32);
    final ciphertext = payload.sublist(33, payload.length - 32);

    final keys = await _messageKeys(conversationKey, nonce);

    final expectedMac = await _hmacSha256(
      keys.hmacKey,
      Uint8List.fromList([...nonce, ...ciphertext]),
    );

    if (!_constantTimeEquals(mac, expectedMac)) {
      throw StateError('NIP-44 MAC verification failed');
    }

    final padded = await _chacha20Decrypt(
      keys.cipherKey,
      keys.chachaNonce,
      ciphertext,
    );
    return utf8.decode(_unpad(padded));
  }

  static Future<Uint8List> conversationKey(Uint8List sharedSecret) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final output = await hkdf.deriveKey(
      secretKey: SecretKey(sharedSecret),
      nonce: utf8.encode(_hkdfSalt),
      info: [],
    );
    return Uint8List.fromList(await output.extractBytes());
  }

  static Future<
    ({Uint8List cipherKey, Uint8List chachaNonce, Uint8List hmacKey})
  >
  _messageKeys(Uint8List convKey, List<int> nonce) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 76);
    final expanded = await hkdf.deriveKey(
      secretKey: SecretKey(convKey),
      nonce: nonce,
      info: [],
    );
    final keyBytes = Uint8List.fromList(await expanded.extractBytes());
    return (
      cipherKey: keyBytes.sublist(0, 32),
      chachaNonce: keyBytes.sublist(32, 44),
      hmacKey: keyBytes.sublist(44, 76),
    );
  }

  static Future<Uint8List> _chacha20Encrypt(
    Uint8List key,
    Uint8List nonce,
    Uint8List plaintext,
  ) async {
    final algorithm = Chacha20(macAlgorithm: MacAlgorithm.empty);
    final secretKey = SecretKey(key);
    final box = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
    );
    return Uint8List.fromList(box.cipherText);
  }

  static Future<Uint8List> _chacha20Decrypt(
    Uint8List key,
    Uint8List nonce,
    Uint8List ciphertext,
  ) async {
    final algorithm = Chacha20(macAlgorithm: MacAlgorithm.empty);
    final secretKey = SecretKey(key);
    final box = SecretBox(ciphertext, nonce: nonce, mac: Mac.empty);
    final plain = await algorithm.decrypt(box, secretKey: secretKey);
    return Uint8List.fromList(plain);
  }

  static Future<Uint8List> _hmacSha256(Uint8List key, Uint8List data) async {
    final hmac = Hmac.sha256();
    final mac = await hmac.calculateMac(data, secretKey: SecretKey(key));
    return Uint8List.fromList(mac.bytes);
  }

  static Uint8List _pad(List<int> plaintext) {
    final length = plaintext.length;
    final unpaddedLen = length + 2;
    int paddedLen = 32;
    while (paddedLen < unpaddedLen) {
      paddedLen *= 2;
    }
    final result = Uint8List(paddedLen);
    result[0] = (length >> 8) & 0xff;
    result[1] = length & 0xff;
    result.setRange(2, 2 + length, plaintext);
    return result;
  }

  static Uint8List _unpad(Uint8List padded) {
    final length = (padded[0] << 8) | padded[1];
    return padded.sublist(2, 2 + length);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  static Uint8List _randomBytes(int count) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(count, (_) => rng.nextInt(256)));
  }
}
