import 'package:mongo_dart/mongo_dart.dart';

class ClinicsRepository {
  ClinicsRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'code': 1},
          'unique': true,
          'name': 'idx_branches_code_unique',
        },
      ],
    });
  }
}
