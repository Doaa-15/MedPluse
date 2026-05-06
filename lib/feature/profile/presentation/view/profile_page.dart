import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/auth/data/datasources/auth_local_data_source.dart';
import 'package:reminder/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reminder/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:reminder/feature/auth/presentation/view/login_page.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_user_data_usecase.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // تم الإبقاء على الـ BlocProvider هنا لضمان تحميل البيانات بمجرد فتح الصفحة
    return BlocProvider(
      create: (context) => ProfileCubit(
        GetUserDataUseCase(ProfileRepositoryImpl()),
        authRepository: AuthRepositoryImpl(          // الـ Repository اللي ضفناه
      remoteDataSource: AuthRemoteDataSourceImpl(),
      localDataSource: AuthLocalDataSourceImpl(),
    ),
      )..loadUserData(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ProfileLoaded) {
            // ❌ تم حذف الـ Scaffold واستبداله بـ Column مباشرة
            return Column(
              children: [
                // الجزء العلوي الذي يحتوي على بيانات المستخدم
                _buildHeader(state, context),
                
                const SizedBox(height: 30),
                
                // قائمة الخيارات
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // استخدمنا SingleChildScrollView لضمان عدم حدوث Overflow في الشاشات الصغيرة
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: "Account Settings",
                            onTap: () {
                              // انتقلي لصفحة تعديل البيانات هنا
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: "Notifications",
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: "Privacy Policy",
                            onTap: () {},
                          ),
                          // استبدلنا Spacer بـ SizedBox لأننا داخل ScrollView
                          const SizedBox(height: 20),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: "Logout",
                            isLogout: true,
                            onTap: () async {
                              // منطق تسجيل الخروج ومسح الـ Hive Box
                           final settings = Hive.box('users_box');

    // 2. مسح القيمة اللي بتحدد إن فيه مستخدم مسجل دخول حالياً
    // بنخلي القيمة null أو نمسح الـ Key تماماً
   await settings.delete('current_user_email');
    // لو عندك توكن أو حالة isLoggedIn امسحيها برضه
    // await settings.put('isLoggedIn', false);

    // 3. توجيه المستخدم لصفحة الـ Login ومسح كل الصفحات السابقة من الـ Stack
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const LoginPage()),
  (route) => false,
);
    }
  },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () => context.read<ProfileCubit>().loadUserData(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // --- الميثودات المساعدة (Header & Menu) تبقى كما هي بدون تغيير ---
  Widget _buildHeader(ProfileLoaded state, BuildContext context) { // مررنا الـ state هنا
  final user = state.user; // استخراج بيانات المستخدم من الـ state

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(top: 60, bottom: 40),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      gradient: AppColors.primaryGradient,
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            // اختيار الصورة من المعرض
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            
            if (image != null) {
              // التأكد من استدعاء الميثود من الـ Cubit
              context.read<ProfileCubit>().updateProfilePicture(File(image.path));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              // عرض الصورة من الرابط إذا وجد، وإلا عرض أيقونة افتراضية
              backgroundImage: (user.profileUrl != null && user.profileUrl!.isNotEmpty)
                  ? NetworkImage(user.profileUrl!)
                  : null,
              child: (user.profileUrl == null || user.profileUrl!.isEmpty)
                  ? const Icon(
                      Icons.camera_alt_rounded,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : AppColors.primary, // تم تغيير اللون ليتماشى مع الثيم
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isLogout ? Colors.red : Colors.grey[400],
        ),
      ),
    );
  }
}