import 'package:hive/hive.dart';

abstract class AuthLocalDataSource {
  Future<void> registerUser(String email, String password, String name);
  Future<bool> loginUser(String email, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final String boxName = 'users_box';

  @override
  Future<void> registerUser(String email, String password, String name) async {
    final box = await Hive.openBox(boxName);
    await box.put('current_user_email', email);
    await box.put(email, {'name': name, 'password': password, 'email': email});
  }

  @override
  Future<bool> loginUser(String email, String password) async {
    var box = Hive.box('users_box');

    if (!box.containsKey(email)) {
      throw Exception(
        "Account not found",
      ); // دي هتروح للـ catch اللي فوق وتطلع "Account not found offline"
    }

    var user = box.get(email);
    return user.password ==
        password; // لو مش متساويين هترجع false وتطلع "Invalid offline credentials"
  }
}
