// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokenModel _$AuthTokenModelFromJson(Map<String, dynamic> json) =>
    _AuthTokenModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      pubkey: json['pubkey'] as String,
    );

Map<String, dynamic> _$AuthTokenModelToJson(_AuthTokenModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'userId': instance.userId,
      'pubkey': instance.pubkey,
    };
