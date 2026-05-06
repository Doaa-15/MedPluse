import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/profile/data/model/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
@override
@override
Future<Either<Failure, UserModel>> getLoggedUser() async {
  try {
    final box = await Hive.openBox('users_box'); // التأكد إنه مفتوح
    final String? currentEmail = box.get('current_user_email');

    if (currentEmail != null) {
      final userData = box.get(currentEmail);
      
      if (userData != null) {
        // تأكدي من مسميات الـ Keys اللي في الـ Map
        return Right(UserModel(
          name: userData['name'] ?? 'No Name',
          email: currentEmail,
          profileUrl: userData['profileUrl'] ?? '',
        ));
      }
    }
    return Left(CacheFailure(message: "User not found locally"));
  } catch (e) {
    return Left(CacheFailure(message: e.toString()));
  }
}
  @override
  Future<Either<Failure, void>> updateProfilePicture(File image) {
    // TODO: implement updateProfilePicture
    throw UnimplementedError();
  }
}