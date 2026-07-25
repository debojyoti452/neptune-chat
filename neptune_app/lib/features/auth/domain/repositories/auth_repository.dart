import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/identity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Identity>> registerIdentity();
  Future<Either<Failure, Identity>> loadIdentity();
  Future<Either<Failure, Unit>> clearIdentity();
}
