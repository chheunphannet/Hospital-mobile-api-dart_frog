import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/doctors_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final doctorsRepo = context.read<DoctorsRepository>();

  return switch (context.request.method) {
    HttpMethod.get => _getDoctorById(id, doctorsRepo),
    HttpMethod.put => _updateDoctor(context, id, doctorsRepo),
    HttpMethod.delete => _deleteDoctor(id, doctorsRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getDoctorById(
  String id,
  DoctorsRepository doctorsRepo,
) async {
  final doctor = await doctorsRepo.findById(id);
  if (doctor == null) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response.json(body: doctor.toJson());
}

Future<Response> _updateDoctor(
  RequestContext context,
  String id,
  DoctorsRepository doctorsRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;

  List<String>? branchesId;
  final branchesList = body['branchesId'] ?? body['branchIds'];
  if (branchesList is List) {
    branchesId = branchesList.map((e) => e.toString()).toList();
  }

  List<String>? languagesSpoken;
  final languagesList = body['languagesSpoken'];
  if (languagesList is List) {
    languagesSpoken = languagesList.map((e) => e.toString()).toList();
  }

  List<String>? qualifications;
  final qualificationsList = body['qualifications'];
  if (qualificationsList is List) {
    qualifications = qualificationsList.map((e) => e.toString()).toList();
  }

  final updatedDoctor = await doctorsRepo.update(
    id: id,
    name: body['name'] as String?,
    title: body['title'] as String?,
    clinicId: body['clinicId'] as String?,
    branchesId: branchesId,
    photoUrl: body['photoUrl'] as String?,
    bio: body['bio'] as String?,
    languagesSpoken: languagesSpoken,
    qualifications: qualifications,
    isAvailableForBooking: body['isAvailableForBooking'] as bool?,
  );

  if (updatedDoctor == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: updatedDoctor.toJson());
}

Future<Response> _deleteDoctor(
  String id,
  DoctorsRepository doctorsRepo,
) async {
  final deleted = await doctorsRepo.delete(id);
  if (!deleted) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response.json(body: {'message': 'Doctor deleted successfully'});
}
