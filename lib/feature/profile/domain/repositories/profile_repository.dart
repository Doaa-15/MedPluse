
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/profile/data/model/user_model.dart';

import '../entities/user_entity.dart';

// هنا بنحدد "إيه" اللي المفروض يحصل، مش "إزاي"
abstract class ProfileRepository {
Future<Either<Failure, UserEntity>> getLoggedUser(); 
  Future<Either<Failure, void>> updateProfilePicture(File image);
}