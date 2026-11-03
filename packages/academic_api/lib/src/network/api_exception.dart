class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthExpiredException extends ApiException {
  AuthExpiredException([super.message = '登录状态已失效']);
}

class AuthException extends ApiException {
  AuthException(super.message, {super.statusCode, super.cause});
}

class ApiFormatException extends ApiException {
  ApiFormatException([super.message = '服务器返回了无法识别的数据']);
}
