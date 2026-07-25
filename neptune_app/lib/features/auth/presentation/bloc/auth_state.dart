import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/identity.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({required Identity identity}) = AuthAuthenticated;
  const factory AuthState.error({required String message}) = AuthError;
}
