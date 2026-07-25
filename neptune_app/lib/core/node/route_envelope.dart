import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_envelope.freezed.dart';
part 'route_envelope.g.dart';

@freezed
abstract class RouteEnvelope with _$RouteEnvelope {
  const factory RouteEnvelope({
    required String messageId,
    required String fromPubkey,
    required String toPubkey,
    required int kind,
    required int createdAt,
    required String payload,
    required String sig,
    @Default(7) int ttl,
    @Default([]) List<String> via,
  }) = _RouteEnvelope;

  factory RouteEnvelope.fromJson(Map<String, dynamic> json) =>
      _$RouteEnvelopeFromJson(json);
}

enum MessageTransport { internet, lan, ble, relay }
