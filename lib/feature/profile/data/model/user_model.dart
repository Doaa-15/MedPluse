import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/profile/domain/entities/user_entity.dart';


@HiveType(typeId: 0) 
class UserModel extends UserEntity {
  @override
  @HiveField(0)
  final String name;

  @override
  @HiveField(1)
  final String email;

  @override
  @HiveField(2)
  final String? profileUrl; 

   UserModel({
    required this.name,
    required this.email,
    this.profileUrl,
  }) : super(name: name, email: email, profileUrl: profileUrl);
}