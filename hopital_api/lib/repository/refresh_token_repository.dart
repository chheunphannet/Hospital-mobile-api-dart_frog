import 'package:mongo_dart/mongo_dart.dart';

class RefreshTokenRepository {
  RefreshTokenRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'expiresAt': 1},
          'name': 'idx_expiresAt_ttl',
          'expireAfterSeconds': 0,
        },
        {
          'key': {'tokenHash': 1},
          'name': 'idx_tokens_hash_unique',
          'unique': true,
        },
        {
          'key': {'userId': 1},
          'name': 'idx_user_id',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create TTL index: $result');
    }
  }
}
