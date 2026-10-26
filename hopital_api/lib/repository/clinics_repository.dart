import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/clinics.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ClinicsRepository {
  ClinicsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('ClinicsRepository');

  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'code': 1},
          'unique': true,
          'name': 'idx_clinics_code_unique',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index $result');
    }
  }

  Future<void> createIndex() => createIndexes();

  Future<Clinics> create(Clinics clinic) async {
    final doc = clinic.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      if (result.writeError?.code == 11000) {
        throw const ConflictException('Clinic code already exists');
      }
      _log.severe('Failed to insert clinic: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert clinic: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Clinics.fromJson(doc);
  }

  Future<List<Clinics>> getAll({int limit = 50, int skip = 0}) async {
    final cursor = _collection.find(
      where.sortBy('name').skip(skip).limit(limit),
    );
    final docs = await cursor.toList();
    return docs.map(Clinics.fromJson).toList();
  }

  Future<Clinics?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Clinics.fromJson(doc);
  }

  Future<Clinics?> findByCode(String code) async {
    final doc = await _collection.findOne(where.eq('code', code));
    if (doc == null) return null;
    return Clinics.fromJson(doc);
  }
}
