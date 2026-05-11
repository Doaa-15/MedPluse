import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/auth/cubit/auth_cubit.dart';
import 'package:reminder/feature/auth/presentation/view/login_page.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/cubit/medications_cubit.dart';
import 'package:reminder/feature/medications/presentation/view/main_wrapper.dart';
import 'package:reminder/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:reminder/injection_container.dart' as di;
import 'package:reminder/injection_container.dart';
import 'package:reminder/localization/cubit/local_cubit.dart';
import 'package:reminder/notification/service/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://aupebzzvjuzskckqmdwr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1cGVienp2anV6c2tja3FtZHdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NDU3NjQsImV4cCI6MjA5MzQyMTc2NH0.w2Q40RCojIEUbbdtRNX_7IAhQkpfV5Je-B-qzywXato',
  );

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MedicationModelAdapter());
  }

  await Hive.openBox('users_box');
  await di.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MultiBlocProvider(
      providers: [
        // 1. إضافة الـ LocaleCubit هنا
        BlocProvider(create: (context) => LocaleCubit()), 
        BlocProvider<MedicationCubit>(
          create: (context) => sl<MedicationCubit>()..fetchMedications(),
        ),
        BlocProvider(create: (context) => sl<AuthCubit>()),
        BlocProvider(create: (context) => sl<ProfileCubit>()..loadUserData()),
      ],
      // 2. استخدام BlocBuilder عشان نراقب تغير اللغة
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, currentLocale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // 3. الربط مع الـ Cubit
            locale: currentLocale, 
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            
            // 4. الصفحة الرئيسية
            home: (user != null) ? const MainWrapper() : const LoginPage(),
          );
        },
      ),
    );
  }
}