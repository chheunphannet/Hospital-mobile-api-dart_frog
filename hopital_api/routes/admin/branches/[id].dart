import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/models/branches.dart';
import 'package:hopital_api/repository/branches_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final branchesRepo = context.read<BranchesRepository>();

  return switch (context.request.method) {
    HttpMethod.get => _getBranchById(id, branchesRepo),
    HttpMethod.put => _updateBranch(context, id, branchesRepo),
    HttpMethod.delete => _deleteBranch(id, branchesRepo),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getBranchById(
  String id,
  BranchesRepository branchesRepo,
) async {
  final branch = await branchesRepo.findById(id);
  if (branch == null) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response.json(body: branch.toJson());
}

Future<Response> _updateBranch(
  RequestContext context,
  String id,
  BranchesRepository branchesRepo,
) async {
  final body = await context.request.json() as Map<String, dynamic>;

  Location? location;
  if (body['location'] is Map<String, dynamic>) {
    location = Location.fromJson(body['location'] as Map<String, dynamic>);
  }

  List<Room>? rooms;
  final roomsList = body['rooms'];
  if (roomsList is List) {
    rooms = roomsList
        .map((e) => Room.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Hardware>? hardwares;
  final hwList = body['hardware'] ?? body['hardwares'];
  if (hwList is List) {
    hardwares = hwList
        .map((e) => Hardware.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<String>? contactNumbers;
  final numbersList = body['contactNumbers'];
  if (numbersList is List) {
    contactNumbers = numbersList.map((e) => e as String).toList();
  }

  final updatedBranch = await branchesRepo.update(
    id: id,
    name: body['name'] as String?,
    contactNumbers: contactNumbers,
    email: body['email'] as String?,
    address: body['address'] as String?,
    location: location,
    rooms: rooms,
    hardwares: hardwares,
  );

  if (updatedBranch == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: updatedBranch.toJson());
}

Future<Response> _deleteBranch(
  String id,
  BranchesRepository branchesRepo,
) async {
  final deleted = await branchesRepo.delete(id);
  if (!deleted) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response.json(body: {'message': 'Branch deleted successfully'});
}
