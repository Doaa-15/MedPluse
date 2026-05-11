import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/auth/domain/usecase/login_usecase.dart';
import 'package:reminder/feature/auth/domain/usecase/register_usecase.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
// حلينا التعارض هنا باستخدام الـ hide
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState; 
import '../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(email, password);

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        await _initializeUserSession(email);
        emit(AuthSuccess());
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await registerUseCase(email, password, name);

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        await _initializeUserSession(email);
        emit(AuthSuccess());
      },
    );
  }

  Future<void> _initializeUserSession(String email) async {
    final boxName = "meds_${email.replaceAll(RegExp(r'[.@]+'), '_')}";
    await Hive.openBox<MedicationModel>(boxName);
    var settings = Hive.box('users_box');
    await settings.put('current_user_box', boxName);
    await settings.flush();
  }

  // ميثود تسجيل الخروج الكاملة
  Future<void> logout() async {
    try {
      // 1. الخروج من Supabase عشان الـ Session تنتهي
      await Supabase.instance.client.auth.signOut();
      
      // 2. مسح بيانات الجلسة من Hive
      var settings = Hive.box('users_box');
      await settings.delete('current_user_box');
      
      emit(AuthLogout());
    } catch (e) {
      emit(AuthError("Logout failed: ${e.toString()}"));
    }
  }
}