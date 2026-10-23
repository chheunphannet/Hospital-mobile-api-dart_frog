import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/service/jwt_service.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final header = context.request.headers['Authorization'];
      if (header == null || !header.startsWith('Bearer ')) {
        throw const UnauthorizedException('Missing token');
      }

      final jwt = context.read<JwtService>().verifyAccessToken(
        header.substring(7),
      );
      return handler(context.provide<JWT>(() => jwt));
    };
  };
}
