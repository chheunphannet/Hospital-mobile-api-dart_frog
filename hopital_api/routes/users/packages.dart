import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/repository/appointments_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final jwt = context.read<JWT>();
  final payload = jwt.payload as Map<String, dynamic>;
  final userId = payload['userId'] as String;

  final appointmentsRepo = context.read<AppointmentsRepository>();
  final queryParam = context.request.uri.queryParameters;

  final packageHistory = await appointmentsRepo.getPackageHistory(
    patientId: userId,
    limit: int.tryParse(queryParam['limit'] ?? '') ?? 20,
    skip: int.tryParse(queryParam['skip'] ?? '') ?? 0,
  );

  return Response.json(
    body: packageHistory.map((e) => e.toJson()).toList(),
  );
}
