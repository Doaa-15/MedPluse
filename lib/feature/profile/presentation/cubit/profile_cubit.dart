import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_state.dart'; // استيراد ملف الـ State
import '../../domain/usecases/get_user_data_usecase.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserDataUseCase getUserDataUseCase;
  final AuthRepositoryImpl authRepository;


  ProfileCubit(this.getUserDataUseCase, {required this.authRepository}) : super(ProfileInitial());
Future<void> loadUserData() async {
    emit(ProfileLoading());
    
    // بنستخدم await لأن العملية بقت Future وبتجيب داتا حقيقية
    final result = await getUserDataUseCase.execute();
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)), 
    );
  }
  // أضيفي هذه الميثود داخل الكلاس
Future<void> updateProfilePicture(File imageFile) async {
  try {
    emit(ProfileLoading()); // إظهار مؤشر تحميل أثناء الرفع

    // 1. نرفع الصورة لـ Supabase وناخد الرابط
    final String? imageUrl = await authRepository.remoteDataSource.uploadProfileImage(imageFile);

    if (imageUrl != null) {
      // 2. تحديث بيانات المستخدم محلياً في الـ Hive عشان الصورة تظهر فوراً
      // (افترضي أن لديكِ كلاس User أو ميثود لتحديثه)
      final box = Hive.box('users_box');
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      
      var userData = box.get(userEmail);
      if (userData != null) {
        userData['profile_url'] = imageUrl;
        await box.put(userEmail, userData);
      }

      // 3. إعادة تحميل البيانات لتحديث الواجهة بالصورة الجديدة
      loadUserData(); 
    }
  } catch (e) {
    emit(ProfileError("فشل رفع الصورة: ${e.toString()}"));
  }
}
}