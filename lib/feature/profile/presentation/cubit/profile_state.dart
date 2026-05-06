import '../../domain/entities/user_entity.dart';

abstract class ProfileState {}

// الحالة الابتدائية
class ProfileInitial extends ProfileState {}

// حالة التحميل (لو بنجيب داتا من السيرفر مثلاً)
class ProfileLoading extends ProfileState {}

// حالة نجاح وصول البيانات
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  ProfileLoaded(this.user);
}

// حالة الفشل
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}