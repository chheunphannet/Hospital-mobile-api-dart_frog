import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/models/users.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UsersRepository {
  UsersRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('UsersRepository');

  Future<Users?> updatedProfile({
    required String userId,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? location,
    String? phoneNumber,
    bool? isProfileCompleted,
    String? avatarUrl,
  }) async {
    final modifier = modify.set('updatedAt', DateTime.now().toUtc());

    if (phoneNumber != null) modifier.set('phoneNumber', phoneNumber);
    if (personalInfo != null) modifier.set('personalInfo', personalInfo);
    if (location != null) modifier.set('location', location);
    if (avatarUrl != null) modifier.set('avatarUrl', avatarUrl);
    if (isProfileCompleted != null) {
      modifier.set('isProfileCompleted', isProfileCompleted);
    }

    final result = await _collection.findAndModify(
      query: where.id(ObjectId.fromHexString(userId)),
      update: modifier,
      returnNew: true, // return new updated doc
    );

    if (result == null) return null;
    return Users.fromJson(result);
  }

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

  Future<Users> createUser(Users user) async {
    final doc = user.toDocument();

    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      if (result.writeError?.code == 11000) {
        final errmsg = result.writeError?.errmsg ?? '';
        if (errmsg.contains('googleId')) {
          throw const ConflictException('Google account already registered');
        }
        throw const ConflictException('Email already registered');
      }
      _log.info('Failed to insert user: ${result.errmsg}');
      throw StateError('Failed to insert user: ${result.errmsg}');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Users.fromJson(doc);
  }

  Future<Users?> findById(String id) async {
    final result = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (result == null) {
      _log.info('User id: $id not found');
      return null;
    }
    return Users.fromJson(result);
  }

  Future<Users?> findByEmail(String email) async {
    final result = await _collection.findOne(where.eq('email', email));
    if (result == null) {
      _log.info('Email : $email not found');
      return null;
    }
    return Users.fromJson(result);
  }

  Future<Users?> findByGoogleId(String googleId) async {
    final result = await _collection.findOne(where.eq('googleId', googleId));
    if (result == null) {
      _log.info('GoogleId : $googleId not found');
      return null;
    }
    return Users.fromJson(result);
  }

  Future<void> linkGoogleAccount({
    required String userId,
    required String googleId,
    String? avatarUrl,
  }) async {
    final modifier = modify
        .set('googleId', googleId)
        .set('isEmailVerified', true)
        .set('updatedAt', DateTime.now().toUtc());

    if (avatarUrl != null) {
      modifier.set('avatarUrl', avatarUrl);
    }

    await _collection.updateOne(
      where.id(ObjectId.fromHexString(userId)),
      modifier,
    );
  }
}
