import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/branches.dart';
import 'package:hopital_api/repository/branches_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final branchesRepo = context.read<BranchesRepository>();

  return switch (context.request.method) {
    HttpMethod.post => _createBranch(context, branchesRepo),
    HttpMethod.get => _getAllBranches(branchesRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createBranch(
  RequestContext context,
  BranchesRepository branchesRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final newBranch = await branchesRepo.createBranch(Branches.fromJson(body));
  return Response.json(
    statusCode: HttpStatus.created,
    body: newBranch.toJson(),
  );
}

Future<Response> _getAllBranches(BranchesRepository branchesRepo) async {
  final branches = await branchesRepo.getAll();
  return Response.json(body: branches.map((e) => e.toJson()).toList());
}
