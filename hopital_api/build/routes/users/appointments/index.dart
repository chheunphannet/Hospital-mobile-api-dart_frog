import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/models/appointments.dart';
import 'package:hopital_api/repository/appointments_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final jwt = context.read<JWT>();
  final payload = jwt.payload as Map<String, dynamic>;

  final userId = payload['userId'] as String;
  final appointmentsRepo = context.read<AppointmentsRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      final body = await context.request.json() as Map<String, dynamic>;
      final app = await appointmentsRepo.createAppointment(
        Appointments(
          patientId: userId,
          packageId: body['packageId'] as String?,
          branchId: body['branchId'] as String,
          department: body['department'] as String,
          patientInfo: PatientInfo.fromJson(
            body['patientInfo'] as Map<String, dynamic>,
          ),
          bookingFor: body['bookingFor'] as String? ?? 'Myself',
          scheduling: Scheduling.fromJson(
            body['scheduling'] as Map<String, dynamic>,
          ),
          personalRequest: body['personalRequest'] as String?,
        ),
      );
      return Response.json(statusCode: HttpStatus.created, body: app.toJson());
    case HttpMethod.get:
      final queryParam = context.request.uri.queryParameters;
      final historyApp = await appointmentsRepo.getDoctorAppointments(
        patientId: userId,
        limit: int.tryParse(queryParam['limit'] ?? '') ?? 20,
        skip: int.tryParse(queryParam['skip'] ?? '') ?? 0,
      );
      return Response.json(body: historyApp.map((e) => e.toJson()).toList());
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
