import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/crypto/key_storage_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/nostr/nostr_key_service.dart';
import '../../domain/entities/identity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final KeyStorageService _keyStorage;

  const AuthRepositoryImpl(this._remote, this._keyStorage);

  @override
  Future<Either<Failure, Identity>> registerIdentity() async {
    try {
      final existing = await _keyStorage.getIdentityPrivKey();
      if (existing != null) {
        final pubkey = NostrKeyService.pubkeyFromPrivkey(existing);
        return Right(Identity(pubkey: pubkey));
      }

      final pair = NostrKeyService.generateKeyPair();
      await _keyStorage.saveIdentityPrivKey(pair.privkey);
      final tokenModel = await _remote.register(pair.pubkey);
      await _keyStorage.saveAuthToken(tokenModel.token);

      return Right(Identity(pubkey: pair.pubkey));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on CryptoException catch (e) {
      return Left(Failure.crypto(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Identity>> loadIdentity() async {
    try {
      final privKey = await _keyStorage.getIdentityPrivKey();
      if (privKey == null) {
        return const Left(Failure.notFound(message: 'No identity found'));
      }
      final pubkey = NostrKeyService.pubkeyFromPrivkey(privKey);
      return Right(Identity(pubkey: pubkey));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearIdentity() async {
    try {
      final token = await _keyStorage.getAuthToken();
      if (token != null) {
        try {
          await _remote.revoke(token);
        } catch (_) {}
        await _keyStorage.deleteAuthToken();
      }
      await _keyStorage.deleteIdentityPrivKey();
      return const Right(unit);
    } catch (e) {
      return Left(Failure.storage(message: e.toString()));
    }
  }
}
