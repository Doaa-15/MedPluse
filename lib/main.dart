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
import 'package:reminder/notification/service/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

Future<void> main() async {
  // 1. التأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aupebzzvjuzskckqmdwr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1cGVienp2anV6c2tja3FtZHdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NDU3NjQsImV4cCI6MjA5MzQyMTc2NH0.w2Q40RCojIEUbbdtRNX_7IAhQkpfV5Je-B-qzywXato',
  );

  // 2. تهيئة Hive والـ Adapters
  await Hive.initFlutter();
 if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(MedicationModelAdapter());
}

  // 3. فتح الـ Boxes (يفضل فتحهم قبل الـ DI إذا كان الـ Injection يعتمد عليهم)
  await Hive.openBox('users_box');
   await di.init();
  
await NotificationService.init();
  
  // طلب الأذونات
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
        // استخدام sl لجلب الـ Cubit مع استدعاء الداتا فوراً
     BlocProvider<MedicationCubit>( // حددي الـ Cubit فقط أو الـ State الجديد
      create: (context) => sl<MedicationCubit>()..fetchMedications(),
    ),
        BlocProvider(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider(
    create: (context) => sl<ProfileCubit>()..loadUserData(),
  ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedSync',
        theme: ThemeData(
          primaryColor: const Color(0xFF238671),
          fontFamily: 'Poppins', // أو أي خط بتستخدميه في البراند
         
          useMaterial3: true,
        ),
      

// التعديل الصحيح للسطر ده
home: (user != null) ? const MainWrapper() : const LoginPage(),
      ),
    );
  }
}