import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/payments.dart';
import 'package:hopital_api/repository/appointments_repository.dart';
import 'package:hopital_api/repository/packages_repository.dart';
import 'package:hopital_api/repository/payments_repository.dart';
import 'package:hopital_api/service/bakong_service.dart';

final _objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');

Future<Response> onRequest(RequestContext context) async {
  final jwt = context.read<JWT>();
  final payload = jwt.payload as Map<String, dynamic>;
  final userId = payload['userId'] as String;

  final paymentsRepo = context.read<PaymentsRepository>();
  final appointmentsRepo = context.read<AppointmentsRepository>();
  final packagesRepo = context.read<PackagesRepository>();
  final bakongService = context.read<BakongService>();

  switch (context.request.method) {
    case HttpMethod.post:
      final body = await context.request.json() as Map<String, dynamic>;
      final amount = (body['amount'] as num?)?.toDouble();
      if (amount == null || amount <= 0) {
        throw const ValidationException('A valid positive amount is required');
      }

      final currency = (body['currency'] as String?)?.toUpperCase() ?? 'USD';
      final appointmentId = body['appointmentId'] as String?;
      final packageId = body['packageId'] as String?;

      // Validate appointmentId if provided
      if (appointmentId != null && appointmentId.isNotEmpty) {
        if (!_objectIdRegex.hasMatch(appointmentId)) {
          throw const ValidationException('Invalid appointmentId format');
        }
        final appointment = await appointmentsRepo.findById(appointmentId);
        if (appointment == null) {
          throw NotFoundException(
            'Appointment not found with ID: $appointmentId',
          );
        }
        if (appointment.patientId != userId) {
          throw const ForbiddenException(
            'You cannot pay for an appointment that does not belong to you',
          );
        }
        if (appointment.status == 'confirmed') {
          throw const ConflictException(
            'This appointment has already been paid and confirmed',
          );
        }
        if (appointment.status == 'cancelled') {
          throw const ValidationException(
            'Cannot make a payment for a cancelled appointment',
          );
        }
      }

      // Validate packageId if provided
      if (packageId != null && packageId.isNotEmpty) {
        if (!_objectIdRegex.hasMatch(packageId)) {
          throw const ValidationException('Invalid packageId format');
        }
        final package = await packagesRepo.findById(packageId);
        if (package == null) {
          throw NotFoundException('Package not found with ID: $packageId');
        }
        if (!package.isActive) {
          throw const ValidationException(
            'The selected checkup package is currently inactive',
          );
        }
      }

      // Generate unique hospital bill number
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final suffix = timestamp.length > 8
          ? timestamp.substring(timestamp.length - 8)
          : timestamp;
      final billNumber = 'ORND-$suffix';

      final khqrResult = bakongService.generateIndividualKhqr(
        amount: amount,
        billNumber: billNumber,
        currency: currency,
      );

      final payment = await paymentsRepo.createPayment(
        Payments(
          patientId: userId,
          appointmentId: appointmentId,
          packageId: packageId,
          billNumber: billNumber,
          amount: amount,
          currency: currency,
          qrString: khqrResult.qrString,
          md5Hash: khqrResult.md5Hash,
          expiresAt: khqrResult.expiresAt,
        ),
      );

      return Response.json(
        statusCode: HttpStatus.created,
        body: payment.toJson(),
      );

    case HttpMethod.get:
      final queryParam = context.request.uri.queryParameters;
      final limit = int.tryParse(queryParam['limit'] ?? '') ?? 20;
      final skip = int.tryParse(queryParam['skip'] ?? '') ?? 0;

      final payments = await paymentsRepo.getPaymentsByPatient(
        patientId: userId,
        limit: limit,
        skip: skip,
      );

      return Response.json(
        body: payments.map((p) => p.toJson()).toList(),
      );

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
