import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_app/core/node/inbound_server.dart';
import 'package:neptune_app/core/nostr/nostr_event.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _testEvent = NostrEvent(
  id: 'aabbccdd11223344',
  pubkey: 'peer_pubkey_hex',
  createdAt: 1700000000,
  kind: 20001,
  tags: [
    ['p', 'my_pubkey_hex'],
  ],
  content: 'encrypted_content',
  sig: 'sig_value_hex',
);

Future<WebSocketChannel> _connect(int port) async {
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:$port'));
  await channel.ready;
  return channel;
}

void main() {
  late InboundServer server;

  setUp(() {
    server = InboundServer();
  });

  tearDown(() async {
    await server.stop();
  });

  group('lifecycle', () {
    test('isRunning is false before start', () {
      expect(server.isRunning, isFalse);
      expect(server.port, isNull);
    });

    test('starts and assigns a non-zero port', () async {
      await server.start();
      expect(server.isRunning, isTrue);
      expect(server.port, isNotNull);
      expect(server.port, greaterThan(0));
    });

    test('stops cleanly and clears port', () async {
      await server.start();
      await server.stop();
      expect(server.isRunning, isFalse);
      expect(server.port, isNull);
    });
  });

  group('event handling', () {
    test('calls onEvent with parsed event when a valid 3-element EVENT arrives', () async {
      await server.start();
      final completer = Completer<NostrEvent>();
      server.onEvent = (event) async => completer.complete(event);

      final channel = await _connect(server.port!);
      channel.sink.add(jsonEncode(['EVENT', 'sub-id', _testEvent.toJson()]));

      final received = await completer.future.timeout(const Duration(seconds: 3));
      await channel.sink.close();

      expect(received.id, _testEvent.id);
      expect(received.pubkey, _testEvent.pubkey);
      expect(received.content, _testEvent.content);
      expect(received.kind, _testEvent.kind);
    });

    test('does not call onEvent for REQ messages', () async {
      await server.start();
      var called = false;
      server.onEvent = (_) async => called = true;

      final channel = await _connect(server.port!);
      channel.sink.add(jsonEncode(['REQ', 'sub-id', {}]));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await channel.sink.close();

      expect(called, isFalse);
    });

    test('does not call onEvent for CLOSE messages', () async {
      await server.start();
      var called = false;
      server.onEvent = (_) async => called = true;

      final channel = await _connect(server.port!);
      channel.sink.add(jsonEncode(['CLOSE', 'sub-id']));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await channel.sink.close();

      expect(called, isFalse);
    });

    test('does not call onEvent for malformed JSON', () async {
      await server.start();
      var called = false;
      server.onEvent = (_) async => called = true;

      final channel = await _connect(server.port!);
      channel.sink.add('not valid json {{{');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await channel.sink.close();

      expect(called, isFalse);
    });

    test('does not call onEvent when onEvent is null', () async {
      await server.start();
      server.onEvent = null;

      final channel = await _connect(server.port!);
      channel.sink.add(jsonEncode(['EVENT', 'sub-id', _testEvent.toJson()]));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await channel.sink.close();
    });

    test('handles multiple concurrent connections', () async {
      await server.start();
      final events = <String>[];
      server.onEvent = (event) async => events.add(event.id);

      final c1 = await _connect(server.port!);
      final c2 = await _connect(server.port!);

      const e1 = NostrEvent(
        id: 'event_id_one',
        pubkey: 'pub1',
        createdAt: 1700000001,
        kind: 20001,
        tags: [],
        content: 'c1',
        sig: 's1',
      );
      const e2 = NostrEvent(
        id: 'event_id_two',
        pubkey: 'pub2',
        createdAt: 1700000002,
        kind: 20001,
        tags: [],
        content: 'c2',
        sig: 's2',
      );

      c1.sink.add(jsonEncode(['EVENT', 'sub', e1.toJson()]));
      c2.sink.add(jsonEncode(['EVENT', 'sub', e2.toJson()]));

      await Future<void>.delayed(const Duration(milliseconds: 300));
      await c1.sink.close();
      await c2.sink.close();

      expect(events, containsAll(['event_id_one', 'event_id_two']));
    });
  });
}
