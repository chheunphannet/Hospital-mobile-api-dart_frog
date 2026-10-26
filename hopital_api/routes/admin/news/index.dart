import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/news.dart';
import 'package:hopital_api/repository/news_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final newsRepo = context.read<NewsRepository>();

  return switch (context.request.method) {
    HttpMethod.post => _createNews(context, newsRepo),
    HttpMethod.get => _getNews(context, newsRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createNews(
  RequestContext context,
  NewsRepository newsRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newNews = await newsRepo.create(News.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newNews.toJson(),
  );
}

Future<Response> _getNews(
  RequestContext context,
  NewsRepository newsRepo,
) async {
  final queryParams = context.request.uri.queryParameters;
  final limit = int.tryParse(queryParams['limit'] ?? '') ?? 50;
  final skip = int.tryParse(queryParams['skip'] ?? '') ?? 0;

  final news = await newsRepo.getAll(limit: limit, skip: skip);
  return Response.json(body: news.map((e) => e.toJson()).toList());
}
