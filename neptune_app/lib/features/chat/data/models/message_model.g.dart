// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      peerPubkey: json['peerPubkey'] as String,
      ciphertext: json['ciphertext'] as String,
      nonce: json['nonce'] as String,
      direction: json['direction'] as String,
      transport: json['transport'] as String,
      sentAt: (json['sentAt'] as num).toInt(),
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'peerPubkey': instance.peerPubkey,
      'ciphertext': instance.ciphertext,
      'nonce': instance.nonce,
      'direction': instance.direction,
      'transport': instance.transport,
      'sentAt': instance.sentAt,
    };
