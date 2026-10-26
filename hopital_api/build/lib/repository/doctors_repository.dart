import 'package:hopital_api/models/doctors.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DoctorsRepository {
  DoctorsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('DoctorsRepository');

  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'branchIds': 1},
          'name': 'idx_doctors_branchIds',
        },
        {
          'key': {'clinicId': 1, 'isAvailableForBooking': 1},
          'name': 'idx_doctors_clinic_booking',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index $result');
    }
  }

  Future<void> createIndex() => createIndexes();

  Future<Doctors> createDoctor(Doctors doctor) async {
    final doc = doctor.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert doctor: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert doctor: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Doctors.fromJson(doc);
  }

  Future<Doctors> create(Doctors doctor) => createDoctor(doctor);

  Future<List<Doctors>> getAll({int limit = 50, int skip = 0}) async {
    final cursor = _collection.find(
      where.sortBy('name').skip(skip).limit(limit),
    );
    final docs = await cursor.toList();
    return docs.map(Doctors.fromJson).toList();
  }

  Future<Doctors?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Doctors.fromJson(doc);
  }

  /// Find doctors ilters clinic, branch, availability, search.
  Future<List<Doctors>> findDoctors({
    String? clinicId,
    String? branchId,
    bool? isAvailable,
    String? search,
    int limit = 50,
    int skip = 0,
  }) async {
    final query = <String, dynamic>{};

    if (clinicId != null && clinicId.isNotEmpty) {
      final oid = _toObjectId(clinicId);
      query['clinicId'] = oid != null
          ? {
              r'$in': [oid, clinicId],
            }
          : clinicId;
    }

    if (branchId != null && branchId.isNotEmpty) {
      final oid = _toObjectId(branchId);
      query['branchIds'] = oid != null
          ? {
              r'$in': [oid, branchId],
            }
          : branchId;
    }

    if (isAvailable != null) {
      query['isAvailableForBooking'] = isAvailable;
    }

    if (search != null && search.trim().isNotEmpty) {
      query['name'] = {r'$regex': search.trim(), r'$options': 'i'};
    }

    final cursor = _collection.find(
      where.raw(query).sortBy('name').skip(skip).limit(limit),
    );
    final docs = await cursor.toList();
    return docs.map(Doctors.fromJson).toList();
  }

  Future<List<Doctors>> findByClinic(
    String clinicId, {
    bool? isAvailable,
    int limit = 50,
    int skip = 0,
  }) {
    return findDoctors(
      clinicId: clinicId,
      isAvailable: isAvailable,
      limit: limit,
      skip: skip,
    );
  }

  Future<List<Doctors>> findByBranch(
    String branchId, {
    bool? isAvailable,
    int limit = 50,
    int skip = 0,
  }) {
    return findDoctors(
      branchId: branchId,
      isAvailable: isAvailable,
      limit: limit,
      skip: skip,
    );
  }

  Future<Doctors?> update({
    required String id,
    String? name,
    String? title,
    String? clinicId,
    List<String>? branchesId,
    String? photoUrl,
    String? bio,
    List<String>? languagesSpoken,
    List<String>? qualifications,
    bool? isAvailableForBooking,
  }) async {
    final modifier = modify;
    if (name != null) modifier.set('name', name);
    if (title != null) modifier.set('title', title);
    if (clinicId != null) {
      modifier.set('clinicId', _toObjectId(clinicId) ?? clinicId);
    }
    if (branchesId != null) {
      modifier.set(
        'branchIds',
        branchesId.map((b) => _toObjectId(b) ?? b).toList(),
      );
    }
    if (photoUrl != null) modifier.set('photoUrl', photoUrl);
    if (bio != null) modifier.set('bio', bio);
    if (languagesSpoken != null) {
      modifier.set('languagesSpoken', languagesSpoken);
    }
    if (qualifications != null) {
      modifier.set('qualifications', qualifications);
    }
    if (isAvailableForBooking != null) {
      modifier.set('isAvailableForBooking', isAvailableForBooking);
    }

    final result = await _collection.findAndModify(
      query: where.id(ObjectId.fromHexString(id)),
      update: modifier,
      returnNew: true,
    );

    if (result == null) return null;
    return Doctors.fromJson(result);
  }

  Future<bool> delete(String id) async {
    final result = await _collection.deleteOne(
      where.id(ObjectId.fromHexString(id)),
    );
    return result.isSuccess;
  }
}

//in MongoDB, an ObjectId must be exactly 24 hexadecimal characters
// If a client passes an invalid string hrows an unhandled ArgumentError.
ObjectId? _toObjectId(String? id) {
  if (id == null) return null;
  try {
    return ObjectId.fromHexString(id);
  } catch (_) {
    return null;
  }
}
