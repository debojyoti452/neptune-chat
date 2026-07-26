import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neptune_app/core/ble/ble_service.dart';
import 'package:neptune_app/core/crypto/key_storage_service.dart';
import 'package:neptune_app/core/discovery/peer_discovery_service.dart';
import 'package:neptune_app/core/node/transport_router.dart';
import 'package:neptune_app/core/nostr/nostr_event.dart';
import 'package:neptune_app/core/nostr/nostr_relay_client.dart';

class MockNostrRelayClient extends Mock implements NostrRelayClient {}

class MockPeerDiscoveryService extends Mock implements PeerDiscoveryService {}

class MockKeyStorageService extends Mock implements KeyStorageService {}

class MockBleService extends Mock implements BleService {}

const _testEvent = NostrEvent(
  id: 'deadbeef00112233',
  pubkey: 'sender_pubkey',
  createdAt: 1700000000,
  kind: 20001,
  tags: [
    ['p', 'peer_pubkey'],
  ],
  content: 'ciphertext',
  sig: 'sig_hex',
);

void main() {
  late MockNostrRelayClient mockRelay;
  late MockPeerDiscoveryService mockDiscovery;
  late MockKeyStorageService mockKeyStorage;
  late MockBleService mockBle;
  late TransportRouter router;

  setUpAll(() {
    registerFallbackValue(_testEvent);
  });

  setUp(() {
    mockRelay = MockNostrRelayClient();
    mockDiscovery = MockPeerDiscoveryService();
    mockKeyStorage = MockKeyStorageService();
    mockBle = MockBleService();

    router = TransportRouter(
      internetRelay: mockRelay,
      discovery: mockDiscovery,
      keyStorage: mockKeyStorage,
      ble: mockBle,
    );

    when(() => mockRelay.state).thenReturn(RelayClientState.disconnected);
    when(() => mockRelay.sendEvent(any())).thenAnswer((_) {});
    when(
      () => mockBle.send(any(), toPubkey: any(named: 'toPubkey')),
    ).thenAnswer((_) async => false);
  });

  group('send — internet relay fallback', () {
    test('sends via internet relay when toPubkey is null', () async {
      await router.send(_testEvent);

      verify(() => mockRelay.sendEvent(_testEvent)).called(1);
      verifyNever(() => mockDiscovery.fetchLanHint(any(), any()));
    });

    test('sends via internet relay when getAuthToken returns null', () async {
      when(() => mockKeyStorage.getAuthToken()).thenAnswer((_) async => null);

      await router.send(_testEvent, toPubkey: 'peer_pubkey');

      verify(() => mockRelay.sendEvent(_testEvent)).called(1);
      verifyNever(() => mockDiscovery.fetchLanHint(any(), any()));
    });

    test('sends via internet relay when fetchLanHint returns null', () async {
      when(() => mockKeyStorage.getAuthToken()).thenAnswer((_) async => 'tok');
      when(
        () => mockDiscovery.fetchLanHint(any(), any()),
      ).thenAnswer((_) async => null);

      await router.send(_testEvent, toPubkey: 'peer_pubkey');

      verify(() => mockRelay.sendEvent(_testEvent)).called(1);
    });
  });

  group('send — LAN path', () {
    late HttpServer captureServer;
    late Completer<String> rawFrameCompleter;

    setUp(() async {
      rawFrameCompleter = Completer<String>();
      captureServer = await HttpServer.bind('127.0.0.1', 0);
      captureServer.transform(WebSocketTransformer()).listen((ws) {
        ws.listen((msg) {
          if (!rawFrameCompleter.isCompleted) {
            rawFrameCompleter.complete(msg as String);
          }
        });
      });

      when(() => mockKeyStorage.getAuthToken()).thenAnswer((_) async => 'tok');
      when(() => mockDiscovery.fetchLanHint(any(), any())).thenAnswer(
        (_) async => PeerHint(ip: '127.0.0.1', port: captureServer.port),
      );
    });

    tearDown(() async {
      await captureServer.close(force: true);
    });

    test(
      'does not fall back to internet relay when LAN hint is available',
      () async {
        await router.send(_testEvent, toPubkey: 'peer_pubkey');

        verifyNever(() => mockRelay.sendEvent(any()));
      },
    );

    test('sends EVENT frame with correct event id and type', () async {
      await router.send(_testEvent, toPubkey: 'peer_pubkey');

      final raw = await rawFrameCompleter.future.timeout(
        const Duration(seconds: 3),
      );
      final frame = jsonDecode(raw) as List<dynamic>;

      expect(frame[0], 'EVENT');
      final eventMap = frame[1] as Map<String, dynamic>;
      expect(eventMap['id'], _testEvent.id);
      expect(eventMap['pubkey'], _testEvent.pubkey);
      expect(eventMap['content'], _testEvent.content);
    });

    test(
      'falls back to internet relay when LAN WebSocket connection fails',
      () async {
        final tmp = await ServerSocket.bind('127.0.0.1', 0);
        final closedPort = tmp.port;
        await tmp.close();

        when(
          () => mockDiscovery.fetchLanHint(any(), any()),
        ).thenAnswer((_) async => PeerHint(ip: '127.0.0.1', port: closedPort));

        await router.send(_testEvent, toPubkey: 'peer_pubkey');

        verify(() => mockRelay.sendEvent(_testEvent)).called(1);
      },
    );
  });
}
