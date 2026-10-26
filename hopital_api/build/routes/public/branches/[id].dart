import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/branches_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final branchesRepo = context.read<BranchesRepository>();
  final branch = await branchesRepo.findById(id);

  if (branch == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: branch.toJson());
}
