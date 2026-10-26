import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/branches.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class BranchesRepository {
  BranchesRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('BranchesRepository');

  // Create indexes for location (2dsphere) and code (unique)
  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'location': '2dsphere'},
          'name': 'idx_branches_geo',
        },
        {
          'key': {'code': 1},
          'name': 'idx_branches_code_unique',
          'unique': true,
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index $result');
    }
  }

  Future<void> createIndex() => createIndexes();

  Future<Branches> create(Branches branches) => createBranch(branches);

  Future<Branches> createBranch(Branches branches) async {
    final doc = branches.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      if (result.writeError?.code == 11000) {
        throw const ConflictException('Branch code already exists');
      }
      _log.severe('Failed to insert branch: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert branch: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Branches.fromJson(doc);
  }

  Future<List<Branches>> getAll() async {
    final docs = await _collection.find().toList();
    return docs.map(Branches.fromJson).toList();
  }

  Future<Branches?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Branches.fromJson(doc);
  }

  Future<Branches?> findByCode(String code) async {
    final doc = await _collection.findOne(where.eq('code', code));
    if (doc == null) return null;
    return Branches.fromJson(doc);
  }

  // Find branches near coordinates
  Future<List<Branches>> findNearby({
    required double longitude,
    required double latitude,
    double? maxDistanceInMeters,
  }) async {
    final query = <String, dynamic>{
      'location': {
        r'$near': {
          //calculates distance
          r'$geometry': {
            //center point of the search
            'type': 'Point',
            'coordinates': [longitude, latitude],
          },
          if (maxDistanceInMeters != null) r'$maxDistance': maxDistanceInMeters,
        },
      },
    };

    final docs = await _collection.find(query).toList();
    return docs.map(Branches.fromJson).toList();
  }

  Future<Branches?> update({
    required String id,
    String? name,
    List<String>? contactNumbers,
    String? email,
    String? address,
    Location? location,
    List<Room>? rooms,
    List<Hardware>? hardwares,
  }) async {
    final modifier = modify;
    if (name != null) modifier.set('name', name);
    if (contactNumbers != null) modifier.set('contactNumbers', contactNumbers);
    if (email != null) modifier.set('email', email);
    if (address != null) modifier.set('address', address);
    if (location != null) modifier.set('location', location.toJson());
    if (rooms != null) {
      modifier.set('rooms', rooms.map((r) => r.toJson()).toList());
    }
    if (hardwares != null) {
      modifier.set('hardware', hardwares.map((h) => h.toJson()).toList());
    }

    final result = await _collection.findAndModify(
      query: where.id(ObjectId.fromHexString(id)),
      update: modifier,
      returnNew: true,
    );

    if (result == null) return null;
    return Branches.fromJson(result);
  }

  Future<bool> delete(String id) async {
    final result = await _collection.deleteOne(
      where.id(ObjectId.fromHexString(id)),
    );
    return result.isSuccess;
  }
}
