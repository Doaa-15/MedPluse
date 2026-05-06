import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/profile/domain/entities/user_entity.dart';
import 'package:reminder/feature/profile/domain/repositories/profile_repository.dart';

class GetUserDataUseCase {
  final ProfileRepository repository;
  GetUserDataUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute() async {
    return await repository.getLoggedUser();
  }
}