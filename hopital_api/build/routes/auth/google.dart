import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/refresh_tokens.dart';
import 'package:hopital_api/service/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final idToken = body['idToken'] as String?;

  if (idToken == null || idToken.isEmpty) {
    throw const ValidationException('Google idToken is required');
  }

  DeviceInfo? deviceInfo;
  if (body['deviceInfo'] is Map<String, dynamic>) {
    deviceInfo = DeviceInfo.fromJson(body['deviceInfo'] as Map<String, dynamic>);
  }

  final authService = context.read<AuthService>();
  final result = await authService.loginWithGoogle(
    idToken: idToken,
    deviceInfo: deviceInfo,
  );

  return Response.json(
    body: result.toJson(),
  );
}
