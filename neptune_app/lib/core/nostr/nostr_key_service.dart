import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

import 'dart:math';

abstract final class NostrKeyService {
  static final ECDomainParameters _curve = ECCurve_secp256k1();

  static ({String privkey, String pubkey}) generateKeyPair() {
    final secureRandom = FortunaRandom()
      ..seed(KeyParameter(_randomBytes(32)));

    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(
        ECKeyGeneratorParameters(_curve),
        secureRandom,
      ));

    final pair = generator.generateKeyPair();
    final priv = pair.privateKey;
    final pub = pair.publicKey;

    final privHex = priv.d!.toRadixString(16).padLeft(64, '0');
    final pubHex = _xOnlyPubkey(pub);

    return (privkey: privHex, pubkey: pubHex);
  }

  static String pubkeyFromPrivkey(String privkeyHex) {
    final privBytes = Uint8List.fromList(hex.decode(privkeyHex));
    final privBigInt = BigInt.parse(hex.encode(privBytes), radix: 16);
    final pubPoint = _curve.G * privBigInt;
    final pub = ECPublicKey(pubPoint, _curve);
    return _xOnlyPubkey(pub);
  }

  static Uint8List ecdh(String privkeyHex, String pubkeyHex) {
    final privBytes = Uint8List.fromList(hex.decode(privkeyHex));
    final privBigInt = BigInt.parse(hex.encode(privBytes), radix: 16);

    final pubBytes = Uint8List.fromList(hex.decode('02$pubkeyHex'));
    final pubPoint = _curve.curve.decodePoint(pubBytes)!;

    final sharedPoint = pubPoint * privBigInt;
    final x = sharedPoint!.x!.toBigInteger()!;

    final xBytes = _bigIntToBytes(x, 32);
    return xBytes;
  }

  static String _xOnlyPubkey(ECPublicKey pub) {
    final x = pub.Q!.x!.toBigInteger()!;
    return x.toRadixString(16).padLeft(64, '0');
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    return Uint8List.fromList(
      List.generate(length, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)),
    );
  }

  static Uint8List _randomBytes(int count) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(count, (_) => rng.nextInt(256)));
  }
}
