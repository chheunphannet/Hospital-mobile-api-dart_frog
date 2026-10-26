import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/health_tips.dart';
import 'package:hopital_api/repository/health_tips_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final tipsRepo = context.read<HealthTipsRepository>();

  return switch (context.request.method) {
    HttpMethod.post => _createTip(context, tipsRepo),
    HttpMethod.get => _getTips(context, tipsRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createTip(
  RequestContext context,
  HealthTipsRepository tipsRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newTip = await tipsRepo.create(HealthTips.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newTip.toJson(),
  );
}

Future<Response> _getTips(
  RequestContext context,
  HealthTipsRepository tipsRepo,
) async {
  final queryParams = context.request.uri.queryParameters;
  final clinic = queryParams['clinic'];
  final isPopularStr = queryParams['isPopular'] ?? queryParams['popular'];
  final isPopular = isPopularStr != null
      ? bool.tryParse(isPopularStr, caseSensitive: false)
      : null;

  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final tips = await tipsRepo.getAll(
    clinic: clinic,
    isPopular: isPopular,
    limit: limit,
    skip: skip,
  );

  return Response.json(body: tips.map((e) => e.toJson()).toList());
}
