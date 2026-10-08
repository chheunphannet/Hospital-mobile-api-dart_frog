import 'package:mongo_dart/mongo_dart.dart';

class UsersRepository {
  UsersRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand(
      {
        'createIndexes': _collection.collectionName,
        'indexes': [
          {
            'key': {'email': 1},
            'name': 'idx_email',
            'unique': true,
          },
          {
            'key': {'googleId': 1},
            'name': 'idx_google_id',
            'unique': true,
            'sparse': true, //skip if null
          },
        ],
      },
    );

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }
}
