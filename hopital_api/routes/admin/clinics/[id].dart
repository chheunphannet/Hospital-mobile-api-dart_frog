import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/clinics_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final clinicsRepo = context.read<ClinicsRepository>();
  final clinic = await clinicsRepo.findById(id);

  if (clinic == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: clinic.toJson());
}
