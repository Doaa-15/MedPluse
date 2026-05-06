class UserEntity {
  final String name;
  final String email;
  final String? profileUrl; // 1. تعريف المتغير

  const UserEntity({
    required this.name,
    required this.email,
    this.profileUrl, // 2. إضافته هنا كـ Named Parameter
  });
}