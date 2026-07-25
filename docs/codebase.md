# Neptune - Codebase Structure

## Flutter App (`neptune_app/lib/`)

```
lib/
├── main.dart                         Entry point
├── bootstrap.dart                    App init: DI setup, DB open, LAN host resolution
├── app.dart                          Root widget + BLoC providers
│
├── core/
│   ├── crypto/
│   │   └── key_storage_service.dart       Identity key read/write via flutter_secure_storage
│   ├── di/
│   │   ├── app_module.dart                GetIt module: singletons + env URL resolution
│   │   ├── injection.dart                 configureDependencies() entrypoint
│   │   └── injection.config.dart          Generated DI graph (do not edit by hand)
│   ├── discovery/
│   │   └── peer_discovery_service.dart    BLE + mDNS + backend peer discovery
│   ├── error/
│   │   ├── exceptions.dart                Raw exception types
│   │   └── failures.dart                  Freezed sealed Failure union (auth/network/storage/notFound)
│   ├── node/
│   │   ├── inbound_server.dart            shelf NIP-01 relay embedded in the device
│   │   ├── route_envelope.dart            Freezed peer-relay envelope (TTL, hops, opaque payload)
│   │   └── transport_router.dart          Transport selection: BLE > LAN > peer > internet
│   ├── nostr/
│   │   ├── nip44_cipher.dart              ECDH + HKDF-SHA256 + ChaCha20-Poly1305 encrypt/decrypt
│   │   ├── nostr_event.dart               Freezed NIP-01 event model + JSON serialisation
│   │   ├── nostr_event_signer.dart        SHA-256 event ID + BIP-340 Schnorr sign
│   │   ├── nostr_key_service.dart         secp256k1 keygen, pubkey derivation, ECDH shared secret
│   │   └── nostr_relay_client.dart        NIP-01 WebSocket client (connect/REQ/EVENT/OK handling)
│   ├── router/
│   │   ├── app_router.dart                go_router routes + auth redirect guard
│   │   └── go_router_refresh_stream.dart  AuthCubit state stream -> GoRouter refresh bridge
│   ├── storage/
│   │   ├── db_schema.dart                 CREATE TABLE DDL for all SQLCipher tables
│   │   └── encrypted_db.dart              SQLCipher singleton: open, migrate, close
│   └── theme/
│       └── app_theme.dart                 Material ThemeData
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart     HTTP POST /auth/register + /auth/revoke
    │   │   ├── models/
    │   │   │   └── auth_token_model.dart            Freezed REST response model
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart        secp256k1 keygen + REST + key storage
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── identity.dart                    Identity value object (pubkey hex)
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart             Abstract interface
    │   │   └── usecases/
    │   │       ├── load_identity.dart               Load existing identity from secure storage
    │   │       └── register_identity.dart           Generate keypair + register with backend
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_cubit.dart                  AuthCubit: initial/authenticated/unauthenticated
    │       │   └── auth_state.dart                  Freezed states
    │       └── views/
    │           └── auth_screen.dart                 First-launch registration screen
    │
    ├── chat/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── chat_local_datasource.dart       SQLCipher message CRUD
    │   │   │   └── chat_session_datasource.dart     SQLCipher session persistence
    │   │   ├── models/
    │   │   │   ├── chat_session_model.dart          Freezed session DB model
    │   │   │   └── message_model.dart               Freezed message DB model (ciphertext at rest)
    │   │   └── repositories/
    │   │       └── chat_repository_impl.dart        Session lifecycle, relay subscribe, E2E encrypt/decrypt
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── chat_session.dart                Session entity (id, peerPubkey, sharedSecret, transport)
    │   │   │   └── message.dart                     Message entity (direction, transport, plaintext)
    │   │   ├── repositories/
    │   │   │   └── chat_repository.dart             Abstract interface
    │   │   └── usecases/
    │   │       ├── load_local_history.dart          Decrypt + load messages from SQLCipher
    │   │       └── send_message.dart                Encrypt + sign + route via TransportRouter
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── chat_bloc.dart                   Session lifecycle + incoming message stream
    │       │   ├── chat_event.dart                  Freezed events: started/sent/received/historyLoaded/ended
    │       │   └── chat_state.dart                  Freezed states: connecting/active/ended/error
    │       ├── views/
    │       │   └── chat_screen.dart                 Real-time chat UI with message list
    │       └── widgets/
    │           └── message_bubble.dart              Sent/received bubble with timestamp
    │
    └── home/
        └── presentation/
            └── views/
                └── home_screen.dart                 Pubkey display + copy button + start chat form
```

---

## Backend (`neptune_backend/lib/`)

```
lib/
├── neptune_backend.ex                           Top-level facade
├── neptune_backend/
│   ├── application.ex                           OTP Application - supervision tree root
│   ├── repo.ex                                  Ecto.Repo (SQLite3 dev/test, PostgreSQL prod)
│   ├── mailer.ex                                Swoosh mailer stub
│   │
│   ├── accounts/
│   │   ├── accounts.ex                          Context: register_or_fetch_user/1, get_user_by_pubkey/1
│   │   └── user.ex                              Ecto schema: id (uuid), pubkey (unique), display_name
│   │
│   ├── auth/
│   │   ├── auth.ex                              Context: issue_token/1, verify_token/1, revoke_token/1
│   │   ├── auth_token.ex                        Ecto schema: token_hash, expires_at, revoked_at, user_id
│   │   └── token.ex                             Token gen (:crypto.strong_rand_bytes) + SHA-256 hash
│   │
│   ├── crypto/
│   │   └── schnorr.ex                           Pure-Elixir BIP-340 Schnorr verify (no NIFs, no C deps)
│   │
│   ├── relay/
│   │   ├── relay.ex                             Facade: validate_event/1, broadcast/1, subscribe/1, unsubscribe/1
│   │   ├── event.ex                             Struct: id, pubkey, created_at, kind, tags, content, sig
│   │   ├── event_validator.ex                   NIP-01 parse + ephemeral kind check + content size + ID hash + Schnorr sig
│   │   ├── event_router.ex                      Phoenix.PubSub: broadcast to relay:p:<pubkey> topics
│   │   └── subscription.ex                      Struct: sub_id, kinds, authors, p_tags
│   │
│   └── signaling/
│       ├── signaling.ex                         Context: upsert_hint/2, get_hints/1
│       ├── peer_hint.ex                         Ecto schema: pubkey, relay_url, expires_at
│       ├── peer_registry.ex                     GenServer: ETS :peer_registry table for live peer presence
│       └── prune_worker.ex                      GenServer: 60s timer, prunes stale hints + expired tokens
│
└── neptune_backend_web/
    ├── neptune_backend_web.ex                   Web macros (controller/router/component helpers)
    ├── endpoint.ex                              Bandit HTTP endpoint config
    ├── router.ex                                Route pipelines: :browser, :api (Bearer auth), raw /nostr
    ├── telemetry.ex                             Phoenix.Telemetry metrics
    ├── gettext.ex                               i18n module
    │
    ├── controllers/
    │   ├── auth_controller.ex                   POST /api/v1/auth/register, POST /api/v1/auth/revoke
    │   ├── auth_json.ex                         JSON view: token response shape
    │   ├── health_controller.ex                 GET /api/v1/health
    │   ├── peer_controller.ex                   GET /api/v1/peers/:pubkey/hints, PUT /api/v1/peers/me/hints
    │   ├── peer_json.ex                         JSON view: hints response shape
    │   ├── page_controller.ex                   GET / dev dashboard
    │   ├── page_html.ex                         HTML view
    │   ├── error_html.ex                        HTML error responses
    │   └── error_json.ex                        JSON error responses
    │
    ├── nostr/
    │   ├── upgrade_controller.ex                GET /nostr - upgrades HTTP to WebSocket via websock_adapter
    │   ├── handler.ex                           WebSock behaviour: EVENT/REQ/CLOSE dispatch + PubSub fan-out
    │   └── message_parser.ex                    NIP-01 JSON frame parser (EVENT/REQ/CLOSE/error)
    │
    ├── plugs/
    │   └── auth_plug.ex                         Assigns current_user from Bearer token, halts on 401
    │
    └── components/
        ├── core_components.ex                   Phoenix LiveView UI components (dev dashboard only)
        └── layouts.ex                           Root layout
```

---

## Tests (`neptune_backend/test/`)

```
test/
├── test_helper.exs
├── support/
│   ├── conn_case.ex                             ConnCase helper for controller tests
│   └── data_case.ex                             DataCase helper for context tests
├── neptune_backend/
│   └── relay/
│       └── event_validator_test.exs             EventValidator: parse, kind range, content size, ID hash, Schnorr
└── neptune_backend_web/
    ├── controllers/
    │   ├── error_html_test.exs
    │   ├── error_json_test.exs
    │   └── page_controller_test.exs
    └── nostr/
        └── message_parser_test.exs              MessageParser: EVENT/REQ/CLOSE/malformed frames
```

---

## Generated Files

These files are auto-generated and must not be edited by hand:

| File | Generator | Trigger |
|------|-----------|---------|
| `*.freezed.dart` | `freezed` | `dart run build_runner build` |
| `*.g.dart` | `json_serializable` | `dart run build_runner build` |
| `injection.config.dart` | `injectable_generator` | `dart run build_runner build` |
