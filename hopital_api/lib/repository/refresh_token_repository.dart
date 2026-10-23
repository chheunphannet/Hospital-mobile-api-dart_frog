import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/refresh_tokens.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RefreshTokenRepository {
  RefreshTokenRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('RefreshTokenRepository');

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

  Future<RefreshTokens> save(RefreshTokens refresh) async {
    final doc = refresh.toDocument();

    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      if (result.writeError?.code == 11000) {
        throw const ConflictException('tokenhash already exist');
      }
      _log.info('Failed to insert user: ${result.errmsg}');
      throw StateError('Failed to insert refresh token: ${result.errmsg}');
    }
    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }

    return RefreshTokens.fromJson(doc);
  }

  Future<RefreshTokens?> findByTokenHash(String tokenHash) async {
    final doc = await _collection.findOne(where.eq('tokenHash', tokenHash));
    if (doc == null) return null;
    return RefreshTokens.fromJson(doc);
  }

  Future<void> revoke(String tokenHash) async {
    await _collection.updateOne(
      where.eq('tokenHash', tokenHash),
      modify.set('isRevoked', true),
    );
  }

  Future<void> revokeAllForUser(String userId) async {
    await _collection.updateMany(
      where.eq('userId', ObjectId.fromHexString(userId)),
      modify.set('isRevoked', true),
    );
  }
}
