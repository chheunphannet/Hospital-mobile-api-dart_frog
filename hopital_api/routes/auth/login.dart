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
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || email.isEmpty) {
    throw const ValidationException('Email is required');
  }
  if (password == null || password.isEmpty) {
    throw const ValidationException('Password is required');
  }

  DeviceInfo? deviceInfo;
  if (body['deviceInfo'] is Map<String, dynamic>) {
    deviceInfo = DeviceInfo.fromJson(body['deviceInfo'] as Map<String, dynamic>);
  }

  final authService = context.read<AuthService>();
  final result = await authService.loginWithPassword(
    email: email,
    password: password,
    deviceInfo: deviceInfo,
  );

  return Response.json(
    body: result.toJson(),
  );
}
