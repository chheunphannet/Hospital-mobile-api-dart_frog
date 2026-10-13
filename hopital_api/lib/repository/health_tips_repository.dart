import 'package:mongo_dart/mongo_dart.dart';

class HealthTipsRepository {
  HealthTipsRepository(this._collection);

  final DbCollection _collection;

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
}
