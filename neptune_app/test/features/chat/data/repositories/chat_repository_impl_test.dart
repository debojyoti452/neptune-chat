import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neptune_app/core/ble/ble_service.dart';
import 'package:neptune_app/core/crypto/key_storage_service.dart';
import 'package:neptune_app/core/discovery/peer_discovery_service.dart';
import 'package:neptune_app/core/error/failures.dart';
import 'package:neptune_app/core/node/inbound_server.dart';
import 'package:neptune_app/core/node/transport_router.dart';
import 'package:neptune_app/core/nostr/nostr_event.dart';
import 'package:neptune_app/core/nostr/nostr_relay_client.dart';
import 'package:neptune_app/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:neptune_app/features/chat/data/datasources/chat_session_datasource.dart';
import 'package:neptune_app/features/chat/data/models/chat_session_model.dart';
import 'package:neptune_app/features/chat/data/models/message_model.dart';
import 'package:neptune_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:neptune_app/features/chat/domain/entities/chat_session.dart';

class MockChatLocalDatasource extends Mock implements ChatLocalDatasource {}

class MockChatSessionDatasource extends Mock implements ChatSessionDatasource {}

class MockKeyStorageService extends Mock implements KeyStorageService {}

class MockTransportRouter extends Mock implements TransportRouter {}

class MockNostrRelayClient extends Mock implements NostrRelayClient {}

class MockInboundServer extends Mock implements InboundServer {}

class MockPeerDiscoveryService extends Mock implements PeerDiscoveryService {}

class MockBleService extends Mock implements BleService {}

const _sessionId = 'session-abc';
const _peerPubkey = 'aabbcc';
const _convKeyHex =
    '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20';

final _sessionModel = ChatSessionModel(
  id: _sessionId,
  peerPubkey: _peerPubkey,
  conversationKeyHex: _convKeyHex,
  transport: 'internet',
  startedAt: 1700000000000,
);

void main() {
  late MockChatLocalDatasource mockLocal;
  late MockChatSessionDatasource mockSessionDs;
  late MockKeyStorageService mockKeyStorage;
  late MockTransportRouter mockRouter;
  late MockNostrRelayClient mockRelay;
  late MockInboundServer mockServer;
  late MockPeerDiscoveryService mockDiscovery;
  late MockBleService mockBle;
  late ChatRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(
      const NostrEvent(
        id: 'id',
        pubkey: 'pk',
        createdAt: 0,
        kind: 0,
        tags: [],
        content: '',
        sig: '',
      ),
    );
    registerFallbackValue(
      MessageModel(
        id: 'id',
        sessionId: _sessionId,
        peerPubkey: _peerPubkey,
        ciphertext: '',
        nonce: '',
        direction: 'sent',
        transport: 'internet',
        sentAt: 0,
      ),
    );
  });

  setUp(() {
    mockLocal = MockChatLocalDatasource();
    mockSessionDs = MockChatSessionDatasource();
    mockKeyStorage = MockKeyStorageService();
    mockRouter = MockTransportRouter();
    mockRelay = MockNostrRelayClient();
    mockServer = MockInboundServer();
    mockDiscovery = MockPeerDiscoveryService();
    mockBle = MockBleService();

    when(() => mockServer.onEvent = any()).thenReturn(null);
    when(() => mockBle.onEvent = any()).thenReturn(null);
    when(() => mockRelay.state).thenReturn(RelayClientState.disconnected);
    when(() => mockServer.port).thenReturn(null);

    repo = ChatRepositoryImpl(
      mockLocal,
      mockSessionDs,
      mockKeyStorage,
      mockRouter,
      mockRelay,
      mockServer,
      mockDiscovery,
      mockBle,
    );
  });

  group('getSessions', () {
    test('returns Right with mapped sessions from datasource', () async {
      when(
        () => mockSessionDs.getAllSessions(),
      ).thenAnswer((_) async => [_sessionModel]);

      final result = await repo.getSessions();

      expect(result, isA<Right>());
      final sessions = (result as Right).value as List<ChatSession>;
      expect(sessions.length, 1);
      expect(sessions.first.id, _sessionId);
      expect(sessions.first.peerPubkey, _peerPubkey);
    });

    test('returns Right with empty list when no sessions', () async {
      when(() => mockSessionDs.getAllSessions()).thenAnswer((_) async => []);

      final result = await repo.getSessions();

      expect(result, isA<Right>());
      expect((result as Right).value, isEmpty);
    });

    test('returns Left(storage) on datasource error', () async {
      when(
        () => mockSessionDs.getAllSessions(),
      ).thenThrow(Exception('db error'));

      final result = await repo.getSessions();

      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('restoreSession', () {
    test('returns Right(session) when session exists in DB', () async {
      when(
        () => mockSessionDs.getSession(_sessionId),
      ).thenAnswer((_) async => _sessionModel);
      when(
        () => mockKeyStorage.getIdentityPrivKey(),
      ).thenAnswer((_) async => null);

      final result = await repo.restoreSession(_sessionId);

      expect(result, isA<Right>());
      final session = (result as Right).value as ChatSession;
      expect(session.id, _sessionId);
      expect(session.peerPubkey, _peerPubkey);
    });

    test(
      'returns Right(session) without error when called twice (idempotent)',
      () async {
        when(
          () => mockSessionDs.getSession(_sessionId),
        ).thenAnswer((_) async => _sessionModel);
        when(
          () => mockKeyStorage.getIdentityPrivKey(),
        ).thenAnswer((_) async => null);

        await repo.restoreSession(_sessionId);
        final result = await repo.restoreSession(_sessionId);

        expect(result, isA<Right>());
        verify(() => mockSessionDs.getSession(_sessionId)).called(1);
      },
    );

    test('returns Left(notFound) when session not in DB', () async {
      when(
        () => mockSessionDs.getSession(_sessionId),
      ).thenAnswer((_) async => null);

      final result = await repo.restoreSession(_sessionId);

      expect(result, isA<Left>());
      final failure = (result as Left).value as Failure;
      expect(failure, isA<Failure>());
    });
  });

  group('loadHistory auto-hydrate', () {
    test(
      'hydrates session from DB and returns empty history when no messages',
      () async {
        when(
          () => mockSessionDs.getSession(_sessionId),
        ).thenAnswer((_) async => _sessionModel);
        when(
          () => mockLocal.getMessages(_sessionId),
        ).thenAnswer((_) async => []);

        final result = await repo.loadHistory(_sessionId);

        expect(result, isA<Right>());
        expect((result as Right).value, isEmpty);
      },
    );

    test('returns Left(notFound) when session not in DB or memory', () async {
      when(
        () => mockSessionDs.getSession(_sessionId),
      ).thenAnswer((_) async => null);

      final result = await repo.loadHistory(_sessionId);

      expect(result, isA<Left>());
    });
  });
}
