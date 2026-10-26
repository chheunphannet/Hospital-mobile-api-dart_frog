import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/repository/users_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final jwt = context.read<JWT>();
  final payload = jwt.payload as Map<String, dynamic>;

  final userId = payload['userId'] as String;
  final userRepo = context.read<UsersRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      final user = await userRepo.findById(userId);
      if (user == null) {
        throw const NotFoundException('User not found');
      }
      return Response.json(body: user.toJson());
    case HttpMethod.patch:
      final body = await context.request.json() as Map<String, dynamic>;
      final updatedUser = await userRepo.updatedProfile(
        userId: userId,
        phoneNumber: body['phoneNumber'] as String?,
        avatarUrl: body['avatarUrl'] as String?,
        personalInfo: body['personalInfo'] as Map<String, dynamic>?,
        location: body['location'] as Map<String, dynamic>?,
        isProfileCompleted: body['isProfileCompleted'] as bool?,
      );

      if (updatedUser == null) throw const NotFoundException('User not found');
      return Response.json(body: updatedUser.toJson());

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
