abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthLogout extends AuthState {} // تأكدي من وجود هذا السطر
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}