import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/service/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final refreshToken = body['refreshToken'] as String?;

  if (refreshToken == null || refreshToken.isEmpty) {
    throw const ValidationException('refreshToken is required');
  }

  final authService = context.read<AuthService>();
  await authService.logout(rawRefreshToken: refreshToken);

  return Response.json(
    body: {'message': 'Logged out successfully'},
  );
}
