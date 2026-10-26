import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/news_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final newsRepo = context.read<NewsRepository>();
  final item = await newsRepo.findById(id);

  if (item == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: item.toJson());
}
