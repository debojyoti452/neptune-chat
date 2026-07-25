import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/node/route_envelope.dart';
import '../../domain/entities/chat_session.dart';

part 'chat_session_model.freezed.dart';

@freezed
abstract class ChatSessionModel with _$ChatSessionModel {
  const factory ChatSessionModel({
    required String id,
    required String peerPubkey,
    required String conversationKeyHex,
    required String transport,
    required int startedAt,
  }) = _ChatSessionModel;

  factory ChatSessionModel.fromMap(Map<String, dynamic> map) => ChatSessionModel(
        id: map['id'] as String,
        peerPubkey: map['peer_id'] as String,
        conversationKeyHex: map['shared_secret'] as String,
        transport: map['transport'] as String,
        startedAt: map['started_at'] as int,
      );
}

extension ChatSessionModelX on ChatSessionModel {
  Map<String, dynamic> toMap() => {
        'id': id,
        'peer_id': peerPubkey,
        'peer_public_key': peerPubkey,
        'shared_secret': conversationKeyHex,
        'transport': transport,
        'started_at': startedAt,
      };

  ChatSession toEntity() => ChatSession(
        id: id,
        peerPubkey: peerPubkey,
        sharedSecret: conversationKeyHex,
        transport: MessageTransport.values.byName(transport),
        startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
      );
}
