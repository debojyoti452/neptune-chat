import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.auth({required String message}) = AuthFailure;
  const factory Failure.storage({required String message}) = StorageFailure;
  const factory Failure.crypto({required String message}) = CryptoFailure;
  const factory Failure.relay({required String message}) = RelayFailure;
  const factory Failure.notFound({required String message}) = NotFoundFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
