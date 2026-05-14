import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/profile/data/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa; 

import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  
  @override
  Future<Either<Failure, UserModel>> getLoggedUser() async {
    try {
      final box = await Hive.openBox('users_box');
      final String? currentEmail = box.get('current_user_email');

      if (currentEmail != null) {
        final userData = box.get(currentEmail);
        if (userData != null) {
          return Right(UserModel(
            name: userData['name'] ?? 'No Name',
            email: currentEmail,
            profileUrl: userData['profileUrl'] ?? '',
          ));
        }
      }
      return const Left(CacheFailure(message: "User not found locally"));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfilePicture(File image) async {
    try {
      final box = await Hive.openBox('users_box');
      final String? currentEmail = box.get('current_user_email');

      if (currentEmail == null) {
        return const Left(CacheFailure(message: "User session not found"));
      }

      final fileName = '${currentEmail}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'avatars/$fileName';

      await supa.Supabase.instance.client.storage
          .from('profile_image') 
          .upload(path, image);

      final String imageUrl = supa.Supabase.instance.client.storage
          .from('profile_image')
          .getPublicUrl(path);

      final userData = box.get(currentEmail);
      if (userData != null) {
        userData['profileUrl'] = imageUrl;
        await box.put(currentEmail, userData);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}