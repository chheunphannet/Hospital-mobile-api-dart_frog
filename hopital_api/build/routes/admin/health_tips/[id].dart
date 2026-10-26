import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/health_tips_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final tipsRepo = context.read<HealthTipsRepository>();
  final tip = await tipsRepo.findById(id);

  if (tip == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: tip.toJson());
}
