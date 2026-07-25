import 'package:equatable/equatable.dart';

import '../../../../core/node/route_envelope.dart';

enum MessageDirection { sent, received }

class Message extends Equatable {
  final String id;
  final String sessionId;
  final String peerPubkey;
  final String content;
  final MessageDirection direction;
  final MessageTransport transport;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.sessionId,
    required this.peerPubkey,
    required this.content,
    required this.direction,
    required this.transport,
    required this.sentAt,
  });

  @override
  List<Object?> get props =>
      [id, sessionId, peerPubkey, content, direction, transport, sentAt];
}
