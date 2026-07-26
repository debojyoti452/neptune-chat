import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_app/core/ble/ble_message_codec.dart';

void main() {
  group('BleMessageCodec round-trip', () {
    test('small message fits in a single chunk', () {
      const json = '{"id":"abc","content":"hello"}';
      final chunks = BleMessageCodec.encode(json, 512);
      expect(chunks.length, 1);

      final decoder = BleMessageDecoder();
      final result = decoder.addChunk(chunks.first);
      expect(result, json);
    });

    test('large message splits into multiple chunks and reassembles', () {
      final json = '{"data":"${'x' * 2000}"}';
      final chunks = BleMessageCodec.encode(json, 64);
      expect(chunks.length, greaterThan(1));

      final decoder = BleMessageDecoder();
      String? result;
      for (final chunk in chunks) {
        result = decoder.addChunk(chunk);
      }
      expect(result, json);
    });

    test('decoder handles byte-by-byte input', () {
      const json = '{"hello":"world"}';
      final chunks = BleMessageCodec.encode(json, 512);
      final allBytes = chunks.expand((c) => c).toList();

      final decoder = BleMessageDecoder();
      String? result;
      for (final byte in allBytes) {
        result = decoder.addChunk(Uint8List.fromList([byte]));
      }
      expect(result, json);
    });

    test('decoder handles back-to-back messages without state leak', () {
      const json1 = '{"msg":1}';
      const json2 = '{"msg":2}';

      final decoder = BleMessageDecoder();

      final chunks1 = BleMessageCodec.encode(json1, 512);
      String? r1;
      for (final chunk in chunks1) {
        r1 = decoder.addChunk(chunk);
      }
      expect(r1, json1);

      final chunks2 = BleMessageCodec.encode(json2, 512);
      String? r2;
      for (final chunk in chunks2) {
        r2 = decoder.addChunk(chunk);
      }
      expect(r2, json2);
    });

    test('encode preserves UTF-8 content', () {
      const json = '{"text":"héllo wörld 🌍"}';
      final chunks = BleMessageCodec.encode(json, 512);
      final decoder = BleMessageDecoder();
      final result = decoder.addChunk(chunks.first);
      expect(result, json);
    });

    test('chunk size respects mtu minus 3 ATT overhead', () {
      const mtu = 23;
      final json = '{"data":"${'a' * 100}"}';
      final chunks = BleMessageCodec.encode(json, mtu);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(mtu - 3));
      }
    });
  });
}
