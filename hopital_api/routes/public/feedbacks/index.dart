import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/feedbacks.dart';
import 'package:hopital_api/repository/feedbacks_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final feedbacksRepo = context.read<FeedbacksRepository>();
  final body = await context.request.json() as Map<String, dynamic>;

  final newFeedback = await feedbacksRepo.create(Feedbacks.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newFeedback.toJson(),
  );
}
