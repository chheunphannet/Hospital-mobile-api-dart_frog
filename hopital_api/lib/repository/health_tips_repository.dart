import 'package:hopital_api/models/health_tips.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class HealthTipsRepository {
  HealthTipsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('HealthTipsRepository');

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'clinic': 1,
            'isPopular': -1,
            'publishedAt': -1,
          },
          'name': 'idx_tips_clinic_popular',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();

  Future<HealthTips> create(HealthTips tip) async {
    final doc = tip.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert health tip: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert health tip: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return HealthTips.fromJson(doc);
  }

  Future<List<HealthTips>> getAll({
    String? clinic,
    bool? isPopular,
    int limit = 50,
    int skip = 0,
  }) async {
    final selector = where.sortBy('publishedAt', descending: true);
    if (clinic != null && clinic.isNotEmpty) {
      selector.eq('clinic', clinic);
    }
    if (isPopular != null) {
      selector.eq('isPopular', isPopular);
    }
    selector.skip(skip).limit(limit);

    final cursor = _collection.find(selector);
    final docs = await cursor.toList();
    return docs.map(HealthTips.fromJson).toList();
  }

  Future<HealthTips?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return HealthTips.fromJson(doc);
  }
}
