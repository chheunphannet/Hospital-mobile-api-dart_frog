import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/clinics.dart';
import 'package:hopital_api/repository/clinics_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final clinicsRepo = context.read<ClinicsRepository>();

  return switch (context.request.method) {
    HttpMethod.post => _createClinic(context, clinicsRepo),
    HttpMethod.get => _getClinics(context, clinicsRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createClinic(
  RequestContext context,
  ClinicsRepository clinicsRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newClinic = await clinicsRepo.create(Clinics.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newClinic.toJson(),
  );
}

Future<Response> _getClinics(
  RequestContext context,
  ClinicsRepository clinicsRepo,
) async {
  final queryParams = context.request.uri.queryParameters;
  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final clinics = await clinicsRepo.getAll(limit: limit, skip: skip);
  return Response.json(body: clinics.map((e) => e.toJson()).toList());
}
