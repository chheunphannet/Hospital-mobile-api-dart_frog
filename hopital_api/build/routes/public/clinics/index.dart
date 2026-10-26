import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/clinics_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final clinicsRepo = context.read<ClinicsRepository>();
  final queryParams = context.request.uri.queryParameters;
  final code = queryParams['code'];

  if (code != null && code.isNotEmpty) {
    final clinic = await clinicsRepo.findByCode(code);
    if (clinic == null) {
      return Response(statusCode: HttpStatus.notFound);
    }
    return Response.json(body: clinic.toJson());
  }

  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final clinics = await clinicsRepo.getAll(limit: limit, skip: skip);
  return Response.json(body: clinics.map((e) => e.toJson()).toList());
}
