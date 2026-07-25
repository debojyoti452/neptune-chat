import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

@injectable
class LoadLocalHistory {
  final ChatRepository _repository;

  const LoadLocalHistory(this._repository);

  Future<Either<Failure, List<Message>>> call(String sessionId) =>
      _repository.loadHistory(sessionId);
}
