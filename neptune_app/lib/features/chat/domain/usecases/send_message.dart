import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class SendMessage {
  final ChatRepository _repository;

  const SendMessage(this._repository);

  Future<Either<Failure, Unit>> call(String sessionId, String content) =>
      _repository.sendMessage(sessionId, content);
}
