import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/repository/appointments_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final jwt = context.read<JWT>();
  final userId = (jwt.payload as Map<String, dynamic>)['userId'] as String;

  final appRepo = context.read<AppointmentsRepository>();
  final app = await appRepo.findById(id);

  if (app == null || app.patientId != userId) {
    throw const NotFoundException('Appointment not found');
  }
  return Response.json(body: app.toJson());
}
