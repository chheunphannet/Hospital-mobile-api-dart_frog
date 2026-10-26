import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/repository/branches_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final branchesRepo = context.read<BranchesRepository>();
  final queryParams = context.request.uri.queryParameters;

  final lat = double.tryParse(queryParams['lat'] ?? '');
  final lng = double.tryParse(queryParams['lng'] ?? '');
  final maxDistance = double.tryParse(queryParams['maxDistance'] ?? '');

  // 1. Nearby search when coordinates are passed
  if (lat != null && lng != null) {
    final nearby = await branchesRepo.findNearby(
      longitude: lng,
      latitude: lat,
      maxDistanceInMeters: maxDistance,
    );
    return Response.json(body: nearby.map((e) => e.toJson()).toList());
  }

  // 2. Lookup by code (?code=DNG)
  final code = queryParams['code'];
  if (code != null && code.isNotEmpty) {
    final branch = await branchesRepo.findByCode(code);
    if (branch == null) {
      return Response(statusCode: HttpStatus.notFound);
    }
    return Response.json(body: branch.toJson());
  }

  // 3. Get all branches
  final branches = await branchesRepo.getAll();
  return Response.json(body: branches.map((e) => e.toJson()).toList());
}
