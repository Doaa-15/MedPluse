import 'package:get_it/get_it.dart';
import 'package:reminder/feature/auth/data/datasources/auth_local_data_source.dart';
import 'package:reminder/feature/profile/data/repositories/profile_repository_impl.dart';
import 'package:reminder/feature/profile/domain/repositories/profile_repository.dart';

// --- Presentation (Cubits) ---
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';
import 'package:reminder/feature/auth/cubit/auth_cubit.dart';
import 'package:reminder/feature/medications/presentation/cubit/medications_cubit.dart';
import 'package:reminder/feature/profile/presentation/cubit/profile_cubit.dart';

// --- Domain (UseCases) ---
import 'package:reminder/feature/add_medication/domain/usecases/add_medication_usecase.dart';
import 'package:reminder/feature/auth/domain/usecase/login_usecase.dart';
import 'package:reminder/feature/auth/domain/usecase/register_usecase.dart';
import 'package:reminder/feature/medications/domain/usecases/get_medications_usecase.dart';
import 'package:reminder/feature/profile/domain/usecases/get_user_data_usecase.dart';

// --- Domain (Repositories Interfaces) ---
import 'package:reminder/feature/auth/domain/repositories/auth_repository.dart';
import 'package:reminder/feature/medications/domain/repositories/medication_repository.dart';

// --- Data (Repositories Implementations) ---
import 'package:reminder/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:reminder/feature/medications/data/repositories/medication_repository_impl.dart';

// --- Data (Data Sources) ---

import 'package:reminder/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reminder/feature/medications/data/datasources/medication_local_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ----------------- 1. Use Cases (Domain Layer) -----------------
  sl.registerLazySingleton(() => AddMedicationUseCase(sl()));
  sl.registerLazySingleton(() => GetMedicationsUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDataUseCase(sl()));

  // ----------------- 2. Cubits (Presentation Layer) -----------------
  // يتم استخدام registerFactory لأننا نحتاج نسخة جديدة من الـ Cubit مع كل فتح للشاشة
  
  sl.registerFactory(
    () => MedicationCubit(
      getMedicationsUseCase: sl(),
      
       medicationRepository: sl(),
    ),
  );

  sl.registerFactory(
        () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(), // هنا GetIt هيدور على AuthRepository اللي إنتِ مسجلاه فوق
    ),
  );

  sl.registerFactory(
    () => AddMedicationCubit(
      addMedicationUseCase: sl(),
    ),
  );

sl.registerFactory(
  () => ProfileCubit(
    profileRepository: sl(), // ده اللي هيشيل ميثود الرفع وميثود الـ Get
  ),
);

  // ----------------- 3. Repositories (Data Layer Implementation) -----------------
  
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(),
  );
// Repositories
sl.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(),
);
// السطر ده صح في ملفك
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ----------------- 4. Data Sources (External & Local) -----------------
  
  // Remote Data Source: يكلم سوبا بيز مباشرة
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(), 
);

  // Local Data Sources: تتعامل مع Hive
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<MedicationLocalDataSource>(
    () => MedicationLocalDataSourceImpl(),
  );

  // ----------------- 5. External Libraries (Optional) -----------------
  // إذا كنتِ تحتاجين لتسجيل SupabaseClient كإعتماد خارجي
  // sl.registerLazySingleton(() => Supabase.instance.client);
}