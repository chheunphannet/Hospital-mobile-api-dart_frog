import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/news_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final newsRepo = context.read<NewsRepository>();
  final queryParams = context.request.uri.queryParameters;
  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final news = await newsRepo.getAll(limit: limit, skip: skip);
  return Response.json(body: news.map((e) => e.toJson()).toList());
}
