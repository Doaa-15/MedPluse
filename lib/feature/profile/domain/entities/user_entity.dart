class UserEntity {
  final String name;
  final String email;
  final String? profileUrl; 

  const UserEntity({
    required this.name,
    required this.email,
    this.profileUrl, 
  });
}