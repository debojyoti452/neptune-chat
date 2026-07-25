import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

import 'nostr_event.dart';

abstract final class NostrEventSigner {
  static final _curve = ECCurve_secp256k1();

  static Future<NostrEvent> buildAndSign({
    required String privkey,
    required String pubkey,
    required int kind,
    required String content,
    required List<List<String>> tags,
    required int createdAt,
  }) async {
    final serialized = jsonEncode([0, pubkey, createdAt, kind, tags, content]);
    final idBytes = await _sha256(utf8.encode(serialized));
    final id = hex.encode(idBytes);
    final sig = await _schnorrSign(
      Uint8List.fromList(hex.decode(privkey)),
      idBytes,
    );
    return NostrEvent(
      id: id,
      pubkey: pubkey,
      createdAt: createdAt,
      kind: kind,
      tags: tags,
      content: content,
      sig: hex.encode(sig),
    );
  }

  static Future<Uint8List> _schnorrSign(
    Uint8List privBytes,
    Uint8List msg,
  ) async {
    final n = _curve.n;
    final d0 = BigInt.parse(hex.encode(privBytes), radix: 16);
    final p = (_curve.G * d0)!;
    final px = _bigIntToBytes(p.x!.toBigInteger()!, 32);
    final d = _hasEvenY(p) ? d0 : n - d0;

    final t = _xor(privBytes, await _taggedHash('BIP0340/aux', Uint8List(32)));
    final kBytes = await _taggedHash(
      'BIP0340/nonce',
      Uint8List.fromList([...t, ...px, ...msg]),
    );
    var k = BigInt.parse(hex.encode(kBytes), radix: 16) % n;
    if (k == BigInt.zero) throw StateError('Schnorr nonce is zero');

    final r = (_curve.G * k)!;
    if (!_hasEvenY(r)) k = n - k;
    final rx = _bigIntToBytes(r.x!.toBigInteger()!, 32);

    final eBytes = await _taggedHash(
      'BIP0340/challenge',
      Uint8List.fromList([...rx, ...px, ...msg]),
    );
    final e = BigInt.parse(hex.encode(eBytes), radix: 16) % n;
    final s = (k + e * d) % n;

    return Uint8List.fromList([...rx, ..._bigIntToBytes(s, 32)]);
  }

  static bool _hasEvenY(ECPoint p) => p.y!.toBigInteger()!.isEven;

  static Uint8List _xor(Uint8List a, Uint8List b) {
    final r = Uint8List(a.length);
    for (var i = 0; i < a.length; i++) {
      r[i] = a[i] ^ b[i];
    }
    return r;
  }

  static Future<Uint8List> _taggedHash(String tag, Uint8List data) async {
    final tagHash = await _sha256(utf8.encode(tag));
    return _sha256(Uint8List.fromList([...tagHash, ...tagHash, ...data]));
  }

  static Future<Uint8List> _sha256(List<int> data) async {
    final hash = await crypto.Sha256().hash(data);
    return Uint8List.fromList(hash.bytes);
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final h = value.toRadixString(16).padLeft(length * 2, '0');
    return Uint8List.fromList(
      List.generate(
        length,
        (i) => int.parse(h.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }
}
