import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/feedbacks_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final feedbacksRepo = context.read<FeedbacksRepository>();
  final feedback = await feedbacksRepo.findById(id);

  if (feedback == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: feedback.toJson());
}
