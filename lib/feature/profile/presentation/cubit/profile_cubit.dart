import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/feature/profile/domain/repositories/profile_repository.dart';
import 'profile_state.dart';

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

  Future<void> updateProfilePicture(File imageFile) async {
    try {
      emit(ProfileLoading());
      final result = await profileRepository.updateProfilePicture(imageFile);

      result.fold(
        (failure) => emit(ProfileError("error in upload image  : ${failure.message}")),
        (_) {
          loadUserData();
        },
      );
    } catch (e) {
      emit(ProfileError("error in upload image  ${e.toString()}"));
    }
  }
}
