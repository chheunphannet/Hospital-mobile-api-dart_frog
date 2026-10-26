import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/health_tips_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final tipsRepo = context.read<HealthTipsRepository>();
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
