// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:neptune_app/core/ble/ble_channel.dart' as _i42;
import 'package:neptune_app/core/ble/ble_service.dart' as _i88;
import 'package:neptune_app/core/crypto/key_storage_service.dart' as _i26;
import 'package:neptune_app/core/di/app_module.dart' as _i317;
import 'package:neptune_app/core/discovery/peer_discovery_service.dart'
    as _i254;
import 'package:neptune_app/core/node/inbound_server.dart' as _i157;
import 'package:neptune_app/core/node/transport_router.dart' as _i435;
import 'package:neptune_app/core/nostr/nostr_relay_client.dart' as _i643;
import 'package:neptune_app/core/storage/encrypted_db.dart' as _i871;
import 'package:neptune_app/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i805;
import 'package:neptune_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i176;
import 'package:neptune_app/features/auth/domain/repositories/auth_repository.dart'
    as _i625;
import 'package:neptune_app/features/auth/domain/usecases/load_identity.dart'
    as _i403;
import 'package:neptune_app/features/auth/domain/usecases/register_identity.dart'
    as _i564;
import 'package:neptune_app/features/auth/presentation/bloc/auth_cubit.dart'
    as _i535;
import 'package:neptune_app/features/chat/data/datasources/chat_local_datasource.dart'
    as _i941;
import 'package:neptune_app/features/chat/data/datasources/chat_session_datasource.dart'
    as _i33;
import 'package:neptune_app/features/chat/data/repositories/chat_repository_impl.dart'
    as _i1054;
import 'package:neptune_app/features/chat/domain/repositories/chat_repository.dart'
    as _i707;
import 'package:neptune_app/features/chat/domain/usecases/load_local_history.dart'
    as _i367;
import 'package:neptune_app/features/chat/domain/usecases/send_message.dart'
    as _i100;
import 'package:neptune_app/features/chat/presentation/bloc/chat_bloc.dart'
    as _i812;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i871.EncryptedDb>(() => appModule.encryptedDb);
    gh.singleton<_i26.KeyStorageService>(() => appModule.keyStorageService);
    gh.singleton<_i643.NostrRelayClient>(() => appModule.nostrRelayClient);
    gh.singleton<_i519.Client>(() => appModule.httpClient);
    gh.singleton<_i42.BleChannel>(() => _i42.BleChannel());
    gh.singleton<_i88.BleService>(() => _i88.BleService(gh<_i42.BleChannel>()));
    gh.singleton<_i254.PeerDiscoveryService>(
      () => _i254.PeerDiscoveryService(
        gh<_i519.Client>(),
        gh<String>(instanceName: 'apiBaseUrl'),
      ),
    );
    gh.singleton<_i157.InboundServer>(() => _i157.InboundServer());
    gh.factory<String>(() => appModule.apiBaseUrl, instanceName: 'apiBaseUrl');
    gh.factory<_i33.ChatSessionDatasource>(
      () => _i33.ChatSessionDatasourceImpl(gh<_i871.EncryptedDb>()),
    );
    gh.factory<_i941.ChatLocalDatasource>(
      () => _i941.ChatLocalDatasourceImpl(gh<_i871.EncryptedDb>()),
    );
    gh.singleton<_i435.TransportRouter>(
      () => _i435.TransportRouter(
        internetRelay: gh<_i643.NostrRelayClient>(),
        discovery: gh<_i254.PeerDiscoveryService>(),
        keyStorage: gh<_i26.KeyStorageService>(),
        ble: gh<_i88.BleService>(),
      ),
    );
    gh.lazySingleton<_i707.ChatRepository>(
      () => _i1054.ChatRepositoryImpl(
        gh<_i941.ChatLocalDatasource>(),
        gh<_i33.ChatSessionDatasource>(),
        gh<_i26.KeyStorageService>(),
        gh<_i435.TransportRouter>(),
        gh<_i643.NostrRelayClient>(),
        gh<_i157.InboundServer>(),
        gh<_i254.PeerDiscoveryService>(),
        gh<_i88.BleService>(),
      ),
    );
    gh.factory<_i805.AuthRemoteDatasource>(
      () => _i805.AuthRemoteDatasourceImpl(
        client: gh<_i519.Client>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
      ),
    );
    gh.factory<_i625.AuthRepository>(
      () => _i176.AuthRepositoryImpl(
        gh<_i805.AuthRemoteDatasource>(),
        gh<_i26.KeyStorageService>(),
      ),
    );
    gh.factory<_i403.LoadIdentity>(
      () => _i403.LoadIdentity(gh<_i625.AuthRepository>()),
    );
    gh.factory<_i564.RegisterIdentity>(
      () => _i564.RegisterIdentity(gh<_i625.AuthRepository>()),
    );
    gh.factory<_i367.LoadLocalHistory>(
      () => _i367.LoadLocalHistory(gh<_i707.ChatRepository>()),
    );
    gh.factory<_i100.SendMessage>(
      () => _i100.SendMessage(gh<_i707.ChatRepository>()),
    );
    gh.factory<_i812.ChatBloc>(
      () => _i812.ChatBloc(
        gh<_i707.ChatRepository>(),
        gh<_i100.SendMessage>(),
        gh<_i367.LoadLocalHistory>(),
      ),
    );
    gh.factory<_i535.AuthCubit>(
      () => _i535.AuthCubit(
        gh<_i403.LoadIdentity>(),
        gh<_i564.RegisterIdentity>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i317.AppModule {}
