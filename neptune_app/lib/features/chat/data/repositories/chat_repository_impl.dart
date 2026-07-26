import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/ble/ble_service.dart';
import '../../../../core/crypto/key_storage_service.dart';
import '../../../../core/discovery/peer_discovery_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/node/inbound_server.dart';
import '../../../../core/node/route_envelope.dart';
import '../../../../core/node/transport_router.dart';
import '../../../../core/nostr/nip44_cipher.dart';
import '../../../../core/nostr/nostr_event.dart';
import '../../../../core/nostr/nostr_event_signer.dart';
import '../../../../core/nostr/nostr_key_service.dart';
import '../../../../core/nostr/nostr_relay_client.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_session_datasource.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDatasource _localDatasource;
  final ChatSessionDatasource _sessionDatasource;
  final KeyStorageService _keyStorage;
  final TransportRouter _router;
  final NostrRelayClient _relay;
  final InboundServer _inboundServer;
  final PeerDiscoveryService _discovery;
  final BleService _bleService;

  final _sessions = <String, (ChatSession, Uint8List)>{};
  final _incomingControllers = <String, StreamController<Message>>{};
  StreamSubscription<NostrEvent>? _relaySub;
  bool _relaySubscribed = false;

  ChatRepositoryImpl(
    this._localDatasource,
    this._sessionDatasource,
    this._keyStorage,
    this._router,
    this._relay,
    this._inboundServer,
    this._discovery,
    this._bleService,
  ) {
    _inboundServer.onEvent = (event) async => _onRelayEvent(event);
    _bleService.onEvent = (event) async => _onRelayEvent(event);
  }

  @override
  Future<Either<Failure, ChatSession>> startSession(String peerPubkey) async {
    try {
      final privkey = await _keyStorage.getIdentityPrivKey();
      if (privkey == null) {
        return const Left(Failure.auth(message: 'No identity key found'));
      }

      final myPubkey = NostrKeyService.pubkeyFromPrivkey(privkey);
      final sharedSecret = NostrKeyService.ecdh(privkey, peerPubkey);
      final convKey = await Nip44Cipher.conversationKey(sharedSecret);

      final session = ChatSession(
        id: const Uuid().v4(),
        peerPubkey: peerPubkey,
        sharedSecret: hex.encode(convKey),
        transport: MessageTransport.internet,
        startedAt: DateTime.now(),
      );

      _sessions[session.id] = (session, convKey);
      _incomingControllers[session.id] = StreamController<Message>.broadcast();

      await _sessionDatasource.saveSession(
        ChatSessionModel(
          id: session.id,
          peerPubkey: peerPubkey,
          conversationKeyHex: hex.encode(convKey),
          transport: session.transport.name,
          startedAt: session.startedAt.millisecondsSinceEpoch,
        ),
      );

      _ensureRelaySubscription(myPubkey).ignore();
      _announceLan().ignore();
      _bleService.start(myPubkey).ignore();
      return Right(session);
    } catch (e) {
      return Left(Failure.network(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(
    String sessionId,
    String content,
  ) async {
    try {
      final cached = _sessions[sessionId];
      if (cached == null) {
        return const Left(Failure.notFound(message: 'Session not found'));
      }
      final (session, convKey) = cached;

      final privkey = await _keyStorage.getIdentityPrivKey();
      if (privkey == null) {
        return const Left(Failure.auth(message: 'No identity key found'));
      }

      final myPubkey = NostrKeyService.pubkeyFromPrivkey(privkey);
      final ciphertext = await Nip44Cipher.encrypt(content, convKey);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final event = await NostrEventSigner.buildAndSign(
        privkey: privkey,
        pubkey: myPubkey,
        kind: 20001,
        content: ciphertext,
        tags: [
          ['p', session.peerPubkey],
        ],
        createdAt: now,
      );

      await _ensureRelaySubscription(myPubkey).onError((e, st) {
        debugPrint('[Neptune] relay: subscription failed: $e');
      });
      debugPrint(
        '[Neptune] relay: sending event ${event.id.substring(0, 8)}... state=${_relay.state}',
      );
      await _router.send(event, toPubkey: session.peerPubkey);

      await _localDatasource.saveMessage(
        MessageModel(
          id: event.id,
          sessionId: sessionId,
          peerPubkey: session.peerPubkey,
          ciphertext: ciphertext,
          nonce: '',
          direction: 'sent',
          transport: session.transport.name,
          sentAt: event.createdAt * 1000,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(Failure.network(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getSessions() async {
    try {
      final models = await _sessionDatasource.getAllSessions();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.storage(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> restoreSession(String sessionId) async {
    try {
      if (_sessions.containsKey(sessionId)) {
        return Right(_sessions[sessionId]!.$1);
      }
      final hydrateResult = await _hydrateSession(sessionId);
      if (hydrateResult == null) {
        return const Left(Failure.notFound(message: 'Session not found'));
      }
      final (session, _) = hydrateResult;

      _incomingControllers[sessionId] ??= StreamController<Message>.broadcast();

      final privkey = await _keyStorage.getIdentityPrivKey();
      if (privkey != null) {
        final myPubkey = NostrKeyService.pubkeyFromPrivkey(privkey);
        _ensureRelaySubscription(myPubkey).ignore();
        _bleService.start(myPubkey).ignore();
      }

      return Right(session);
    } catch (e) {
      return Left(Failure.network(message: e.toString()));
    }
  }

  Future<(ChatSession, Uint8List)?> _hydrateSession(String sessionId) async {
    final cached = _sessions[sessionId];
    if (cached != null) return cached;

    final model = await _sessionDatasource.getSession(sessionId);
    if (model == null) return null;

    final convKey = Uint8List.fromList(
      List.generate(
        model.conversationKeyHex.length ~/ 2,
        (i) => int.parse(
          model.conversationKeyHex.substring(i * 2, i * 2 + 2),
          radix: 16,
        ),
      ),
    );

    final session = model.toEntity();
    _sessions[sessionId] = (session, convKey);
    return (session, convKey);
  }

  @override
  Future<Either<Failure, List<Message>>> loadHistory(String sessionId) async {
    try {
      await _hydrateSession(sessionId);

      final cached = _sessions[sessionId];
      if (cached == null) {
        return const Left(Failure.notFound(message: 'Session not found'));
      }
      final (_, convKey) = cached;

      final models = await _localDatasource.getMessages(sessionId);
      final messages = <Message>[];
      for (final model in models) {
        try {
          final plaintext = await Nip44Cipher.decrypt(
            model.ciphertext,
            convKey,
          );
          messages.add(model.toEntity(plaintext));
        } catch (_) {}
      }
      return Right(messages);
    } catch (e) {
      return Left(Failure.storage(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> endSession(String sessionId) async {
    try {
      _sessions.remove(sessionId);
      await _incomingControllers.remove(sessionId)?.close();
      await _localDatasource.deleteSession(sessionId);
      await _sessionDatasource.deleteSession(sessionId);

      if (_sessions.isEmpty) {
        _relay.unsubscribe('neptune-incoming');
        await _relaySub?.cancel();
        _relaySub = null;
        _relaySubscribed = false;
        await _bleService.stop();
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure.storage(message: e.toString()));
    }
  }

  @override
  Stream<Message> incomingMessages(String sessionId) {
    return _incomingControllers[sessionId]?.stream ?? const Stream.empty();
  }

  Future<void> _ensureRelaySubscription(String myPubkey) async {
    final needsSubscribe =
        !_relaySubscribed || _relay.state == RelayClientState.disconnected;
    debugPrint('[Neptune] relay: connect() state=${_relay.state}');
    await _relay.connect();
    debugPrint('[Neptune] relay: connected, needsSubscribe=$needsSubscribe');
    if (needsSubscribe) {
      _relay.subscribe('neptune-incoming', [
        {
          'kinds': [20001],
          '#p': [myPubkey],
          'since': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ]);
      debugPrint(
        '[Neptune] relay: subscribed for #p:${myPubkey.substring(0, 8)}...',
      );
      if (!_relaySubscribed) {
        _relaySub = _relay.events.listen(_onRelayEvent);
        _relaySubscribed = true;
      }
    }
  }

  void _onRelayEvent(NostrEvent event) {
    debugPrint(
      '[Neptune] relay: EVENT from ${event.pubkey.substring(0, 8)}... kind=${event.kind}',
    );
    for (final entry in _sessions.entries) {
      if (entry.value.$1.peerPubkey == event.pubkey) {
        _handleIncomingEvent(entry.key, entry.value.$1, entry.value.$2, event);
      }
    }
  }

  Future<void> _announceLan() async {
    try {
      final token = await _keyStorage.getAuthToken();
      if (token == null) return;
      final ip = await _discovery.localIpAddress();
      if (ip == null) return;
      final port = _inboundServer.port;
      if (port == null) return;
      await _discovery.announceLan(ip: ip, port: port, token: token);
      debugPrint('[Neptune] LAN: announced $ip:$port');
    } catch (_) {}
  }

  Future<void> _handleIncomingEvent(
    String sessionId,
    ChatSession session,
    Uint8List convKey,
    NostrEvent event,
  ) async {
    try {
      final plaintext = await Nip44Cipher.decrypt(event.content, convKey);

      await _localDatasource.saveMessage(
        MessageModel(
          id: event.id,
          sessionId: sessionId,
          peerPubkey: event.pubkey,
          ciphertext: event.content,
          nonce: '',
          direction: 'received',
          transport: session.transport.name,
          sentAt: event.createdAt * 1000,
        ),
      );

      _incomingControllers[sessionId]?.add(
        Message(
          id: event.id,
          sessionId: sessionId,
          peerPubkey: event.pubkey,
          content: plaintext,
          direction: MessageDirection.received,
          transport: session.transport,
          sentAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
        ),
      );
    } catch (_) {}
  }
}
