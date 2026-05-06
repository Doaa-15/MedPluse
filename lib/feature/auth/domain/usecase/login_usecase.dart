import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/auth/domain/repositories/auth_repository.dart';


class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}