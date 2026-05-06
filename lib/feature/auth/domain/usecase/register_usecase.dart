import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';

import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String password, String name) async {
    return await repository.register(email, password, name);
  }
}