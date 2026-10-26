import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/doctors.dart';
import 'package:hopital_api/repository/doctors_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final doctorsRepo = context.read<DoctorsRepository>();

  return switch (context.request.method) {
    HttpMethod.post => _createDoctor(context, doctorsRepo),
    HttpMethod.get => _getDoctors(context, doctorsRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createDoctor(
  RequestContext context,
  DoctorsRepository doctorsRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newDoctor = await doctorsRepo.createDoctor(Doctors.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newDoctor.toJson(),
  );
}

Future<Response> _getDoctors(
  RequestContext context,
  DoctorsRepository doctorsRepo,
) async {
  final queryParams = context.request.uri.queryParameters;
  final clinicId = queryParams['clinicId'];
  final branchId = queryParams['branchId'];
  final search = queryParams['search'] ?? queryParams['q'];
  final isAvailableStr = queryParams['isAvailable'] ?? queryParams['available'];
  final isAvailable = isAvailableStr != null
      ? bool.tryParse(isAvailableStr, caseSensitive: false)
      : null;

  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final doctors = await doctorsRepo.findDoctors(
    clinicId: clinicId,
    branchId: branchId,
    isAvailable: isAvailable,
    search: search,
    limit: limit,
    skip: skip,
  );

  return Response.json(body: doctors.map((e) => e.toJson()).toList());
}
