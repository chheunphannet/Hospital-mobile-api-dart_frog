import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/feedbacks.dart';
import 'package:hopital_api/repository/feedbacks_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final feedbacksRepo = context.read<FeedbacksRepository>();

  return switch (context.request.method) {
    HttpMethod.get => _getFeedbacks(context, feedbacksRepo),
    HttpMethod.post => _createFeedback(context, feedbacksRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getFeedbacks(
  RequestContext context,
  FeedbacksRepository feedbacksRepo,
) async {
  final queryParams = context.request.uri.queryParameters;
  final status = queryParams['status'];
  final priority = queryParams['priority'];
  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final feedbacks = await feedbacksRepo.getAll(
    status: status,
    priority: priority,
    limit: limit,
    skip: skip,
  );

  return Response.json(body: feedbacks.map((e) => e.toJson()).toList());
}

Future<Response> _createFeedback(
  RequestContext context,
  FeedbacksRepository feedbacksRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newFeedback = await feedbacksRepo.create(Feedbacks.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newFeedback.toJson(),
  );
}
