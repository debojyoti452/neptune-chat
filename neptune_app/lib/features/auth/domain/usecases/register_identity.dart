import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/identity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterIdentity {
  final AuthRepository _repository;

  const RegisterIdentity(this._repository);

  Future<Either<Failure, Identity>> call() => _repository.registerIdentity();
}
