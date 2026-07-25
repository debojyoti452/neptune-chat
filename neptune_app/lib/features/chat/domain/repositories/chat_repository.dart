import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chat_session.dart';
import '../entities/message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, ChatSession>> startSession(String peerPubkey);
  Future<Either<Failure, Unit>> sendMessage(String sessionId, String content);
  Future<Either<Failure, List<Message>>> loadHistory(String sessionId);
  Future<Either<Failure, Unit>> endSession(String sessionId);
  Stream<Message> incomingMessages(String sessionId);
}
