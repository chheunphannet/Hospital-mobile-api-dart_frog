import 'package:hopital_api/models/packages.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PackagesRepository {
  PackagesRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('PackagesRepository');

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'metadata.supportedBranchIds': 1,
            'isActive': 1,
          },
          'name': 'idx_packages_branch_active',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();

  Future<Packages> create(Packages package) async {
    final doc = package.toJson();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert package: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert package: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Packages.fromJson(doc);
  }

  Future<List<Packages>> getAll({int limit = 50, int skip = 0}) async {
    final cursor = _collection.find(where.skip(skip).limit(limit));
    final docs = await cursor.toList();
    return docs.map(Packages.fromJson).toList();
  }

  Future<Packages?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Packages.fromJson(doc);
  }
}
