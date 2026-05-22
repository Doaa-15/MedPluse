abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'حدث خطأ في السيرفر'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'فشل في استعادة البيانات المحلية'}) : super(message);
}