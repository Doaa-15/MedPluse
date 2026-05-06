import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';


abstract class AuthRepository {
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> register(String email, String password, String name);
}