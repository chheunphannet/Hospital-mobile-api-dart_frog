import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/repository/appointments_repository.dart';
import 'package:hopital_api/repository/payments_repository.dart';
import 'package:hopital_api/service/bakong_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final jwt = context.read<JWT>();
  final payload = jwt.payload as Map<String, dynamic>;
  final userId = payload['userId'] as String;

  final paymentsRepo = context.read<PaymentsRepository>();
  final appointmentsRepo = context.read<AppointmentsRepository>();
  final bakongService = context.read<BakongService>();

  if (context.request.method != HttpMethod.get &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final payment = await paymentsRepo.findById(id);
  if (payment == null) {
    throw const NotFoundException('Payment record not found');
  }

  if (payment.patientId != userId) {
    throw const ForbiddenException('You do not have access to this payment');
  }

  // Already marked as paid
  if (payment.status == 'paid') {
    return Response.json(
      body: {
        'success': true,
        'status': 'paid',
        'payment': payment.toJson(),
      },
    );
  }

  // Check with NBC Bakong Open API
  final result = await bakongService.checkTransactionStatus(payment.md5Hash);

  if (result.isPaid) {
    final updatedPayment = await paymentsRepo.updatePaymentStatus(
      id: payment.id!,
      status: 'paid',
      transactionHash: result.transactionHash,
      fromAccountId: result.fromAccountId,
      paidAt: DateTime.now().toUtc(),
    );

    // If payment was for an appointment, automatically confirm the appointment
    if (payment.appointmentId != null) {
      await appointmentsRepo.updateStatus(payment.appointmentId!, 'confirmed');
    }

    return Response.json(
      body: {
        'success': true,
        'status': 'paid',
        'payment': updatedPayment?.toJson() ?? payment.toJson(),
      },
    );
  }

  // Still pending or not yet settled
  return Response.json(
    body: {
      'success': false,
      'status': payment.status,
      'message': result.message,
      'payment': payment.toJson(),
    },
  );
}
