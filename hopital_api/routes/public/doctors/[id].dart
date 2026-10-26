import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/doctors_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final doctorsRepo = context.read<DoctorsRepository>();
  final doctor = await doctorsRepo.findById(id);

  if (doctor == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: doctor.toJson());
}
