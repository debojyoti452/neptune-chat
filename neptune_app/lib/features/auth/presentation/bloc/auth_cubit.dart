import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/load_identity.dart';
import '../../domain/usecases/register_identity.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoadIdentity _loadIdentity;
  final RegisterIdentity _registerIdentity;

  AuthCubit(this._loadIdentity, this._registerIdentity)
      : super(const AuthState.initial());

  Future<void> initialize() async {
    emit(const AuthState.loading());

    final result = await _loadIdentity();

    result.fold(
      (_) => _createNewIdentity(),
      (identity) {
        debugPrint('[Neptune] identity pubkey: ${identity.pubkey}');
        emit(AuthState.authenticated(identity: identity));
      },
    );
  }

  Future<void> _createNewIdentity() async {
    final result = await _registerIdentity();
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (identity) {
        debugPrint('[Neptune] identity pubkey: ${identity.pubkey}');
        emit(AuthState.authenticated(identity: identity));
      },
    );
  }
}
