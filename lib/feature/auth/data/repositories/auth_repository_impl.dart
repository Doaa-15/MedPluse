import 'package:dartz/dartz.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/auth/data/datasources/auth_local_data_source.dart';
import 'package:reminder/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:reminder/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, void>> login(String email, String password) async {
    try {

      final userResponse = await remoteDataSource.signIn(email, password);

      if (userResponse.user != null) {
      
        await localDataSource.registerUser(
          userResponse.user!.email!,
          password, 
          userResponse.user!.userMetadata?['full_name'] ?? 'User',
        );
        return const Right(null);
      } else {
        return const Left(
          ServerFailure(message: "حدث خطأ غير متوقع أثناء تسجيل الدخول"),
        );
      }
    } catch (e) {

      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('not found') ||
          errorMessage.contains('no user')) {
        return const Left(
          ServerFailure(
            message: "Account does not exist or invalid credentials",
          ),
        );
      }

      try {
        final success = await localDataSource.loginUser(email, password);
        if (success) {
          return const Right(null);
        } else {
   
          return const Left(CacheFailure(message: "Invalid offline credentials"));
        }
      } catch (cacheError) {
        return const Left(
          CacheFailure(
            message:
                "Account does not exist locally. Please connect to internet.",
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await remoteDataSource.signUp(email, password, name);

      if (response.user != null) {
        await localDataSource.registerUser(email, password, name);
        return const Right(null);
      } else {
        return const Left(ServerFailure(message: "Could not create user account"));
      }
    } catch (e) {
      // هندلة لو الإيميل موجود قبل كدة
      if (e.toString().contains('already registered')) {
        return const Left(ServerFailure(message: "This email is already in use"));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
