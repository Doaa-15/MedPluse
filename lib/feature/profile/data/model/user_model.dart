import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/profile/domain/entities/user_entity.dart';


@HiveType(typeId: 0) // تأكدي من استخدام نفس الـ typeId الخاص بالكلاس
class UserModel extends UserEntity {
  @override
  @HiveField(0)
  final String name;

  @override
  @HiveField(1)
  final String email;

  @override
  @HiveField(2) // أضيفي الاندكس التالي هنا
  final String? profileUrl; 

   UserModel({
    required this.name,
    required this.email,
    this.profileUrl,
  }) : super(name: name, email: email, profileUrl: profileUrl);
}