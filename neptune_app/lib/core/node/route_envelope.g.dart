// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteEnvelope _$RouteEnvelopeFromJson(Map<String, dynamic> json) =>
    _RouteEnvelope(
      messageId: json['messageId'] as String,
      fromPubkey: json['fromPubkey'] as String,
      toPubkey: json['toPubkey'] as String,
      kind: (json['kind'] as num).toInt(),
      createdAt: (json['createdAt'] as num).toInt(),
      payload: json['payload'] as String,
      sig: json['sig'] as String,
      ttl: (json['ttl'] as num?)?.toInt() ?? 7,
      via:
          (json['via'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$RouteEnvelopeToJson(_RouteEnvelope instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'fromPubkey': instance.fromPubkey,
      'toPubkey': instance.toPubkey,
      'kind': instance.kind,
      'createdAt': instance.createdAt,
      'payload': instance.payload,
      'sig': instance.sig,
      'ttl': instance.ttl,
      'via': instance.via,
    };
