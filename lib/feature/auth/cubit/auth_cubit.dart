import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/auth/domain/usecase/login_usecase.dart';
import 'package:reminder/feature/auth/domain/usecase/register_usecase.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
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

  // --- ميثود تسجيل الدخول (Login) ---
  // --- ميثود تسجيل الدخول (Login) ---
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    // التعديل هنا: تمرير email و password مباشرة بدون LoginParams
    final result = await loginUseCase(email, password);

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        // نجاح في السيرفر -> نفتح الـ Hive ونحفظ الجلسة
        await _initializeUserSession(email);
        emit(AuthSuccess());
      },
    );
  }

  // --- ميثود إنشاء حساب (Register) ---
  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());

    // 1. طلب الـ UseCase والانتظار (await)
    final result = await registerUseCase(email, password, name);

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        // نجاح في السيرفر -> ننشئ الجلسة محلياً
        await _initializeUserSession(email);
        emit(AuthSuccess());
      },
    );
  }

  // ميثود مساعدة لتنظيم الكود ومنع التكرار (Helper Method)
  Future<void> _initializeUserSession(String email) async {
    final boxName = "meds_${email.replaceAll(RegExp(r'[.@]+'), '_')}";
    await Hive.openBox<MedicationModel>(boxName);
    var settings = Hive.box('users_box');
    await settings.put('current_user_box', boxName);
    await settings.flush();
  }

  // --- تسجيل الخروج ---
  Future<void> logout() async {
    try {
      var settings = Hive.box('users_box');
      await settings.delete('current_user_box');
      emit(AuthLogout());
    } catch (e) {
      emit(AuthError("Logout failed: ${e.toString()}"));
    }
  }
}