import 'package:mongo_dart/mongo_dart.dart';

class BranchesRepository {
  BranchesRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'location': '2dsphere'}, //
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
      StateError('Failed to create index $result');
    }
  }
}
