import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/node/route_envelope.dart';
import '../../domain/entities/message.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String sessionId,
    required String peerPubkey,
    required String ciphertext,
    required String nonce,
    required String direction,
    required String transport,
    required int sentAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    id: map['id'] as String,
    sessionId: map['session_id'] as String,
    peerPubkey: map['peer_id'] as String,
    ciphertext: map['ciphertext'] as String,
    nonce: map['nonce'] as String,
    direction: map['direction'] as String,
    transport: map['transport'] as String,
    sentAt: map['sent_at'] as int,
  );
}

extension MessageModelX on MessageModel {
  Map<String, dynamic> toMap() => {
    'id': id,
    'session_id': sessionId,
    'peer_id': peerPubkey,
    'ciphertext': ciphertext,
    'nonce': nonce,
    'direction': direction,
    'transport': transport,
    'sent_at': sentAt,
  };

  Message toEntity(String decryptedContent) => Message(
    id: id,
    sessionId: sessionId,
    peerPubkey: peerPubkey,
    content: decryptedContent,
    direction: direction == 'sent'
        ? MessageDirection.sent
        : MessageDirection.received,
    transport: MessageTransport.values.byName(transport),
    sentAt: DateTime.fromMillisecondsSinceEpoch(sentAt),
  );
}
