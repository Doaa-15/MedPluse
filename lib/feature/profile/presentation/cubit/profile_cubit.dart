import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/feature/profile/domain/repositories/profile_repository.dart';
import 'profile_state.dart'; // استيراد ملف الـ State

class ProfileCubit extends Cubit<ProfileState> {

  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository} )
      : super(ProfileInitial());
Future<void> loadUserData() async {
    final result = await profileRepository.getLoggedUser();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  // أضيفي هذه الميثود داخل الكلاس
  Future<void> updateProfilePicture(File imageFile) async {
    try {
      emit(ProfileLoading());

      // التعديل هنا: استخدمي الـ profileRepository اللي جواه الميثود اللي كتبناها
      final result = await profileRepository.updateProfilePicture(imageFile);

      result.fold(
        (failure) => emit(ProfileError("فشل رفع الصورة: ${failure.message}")),
        (_) {
          // لو نجح، هو أصلاً بيحدث الـ Hive جوه الـ Repository
          // فإحنا بس بنعمل إعادة تحميل للبيانات في الـ UI
          loadUserData();
        },
      );
    } catch (e) {
      emit(ProfileError("فشل رفع الصورة: ${e.toString()}"));
    }
  }
}
