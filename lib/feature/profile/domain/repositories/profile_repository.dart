
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';

import '../entities/user_entity.dart';

abstract class ProfileRepository {
Future<Either<Failure, UserEntity>> getLoggedUser(); 
  Future<Either<Failure, void>> updateProfilePicture(File image);
}