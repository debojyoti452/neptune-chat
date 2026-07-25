import 'package:equatable/equatable.dart';

import '../../../../core/node/route_envelope.dart';

class ChatSession extends Equatable {
  final String id;
  final String peerPubkey;
  final String sharedSecret;
  final MessageTransport transport;
  final DateTime startedAt;

  const ChatSession({
    required this.id,
    required this.peerPubkey,
    required this.sharedSecret,
    required this.transport,
    required this.startedAt,
  });

  @override
  List<Object?> get props => [id, peerPubkey, transport, startedAt];
}
