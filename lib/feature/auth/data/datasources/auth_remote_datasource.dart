import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signUp(String email, String password, String name);
  Future<AuthResponse> signIn(String email, String password);
  Future<void> signOut();
  Future<String?> uploadProfileImage(File imageFile);
  
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<AuthResponse> signUp(String email, String password, String name) async {
    // 1. إنشاء حساب في Authentication
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name}, // تخزين الاسم كـ Metadata
    );

    // 2. اختيارياً: يمكنك هنا إضافة البيانات لجدول 'profiles' في الـ Database
    return response;
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
@override
Future<String?> uploadProfileImage(File imageFile) async {
  try {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    // المسار لازم يطابق الـ Policy (Bucket Name: profile_images)
    final fileName = '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.png'; 

    await _supabaseClient.storage.from('profile_images').upload(
      fileName,
      imageFile,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabaseClient.storage.from('profile_images').getPublicUrl(fileName);
  } catch (e) {
    throw Exception("فشل رفع الصورة: $e");
  }
}
}