import 'package:mongo_dart/mongo_dart.dart';

class DoctorsRepository {
  DoctorsRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndexes() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'branchIds': 1},
          'name': 'idx_doctors_branchIds',
        },
        {
          'key': {'clinicId': 1},
          'name': 'idx_doctors_clinic_booking',
        },
      ],
    });

    if (result['ok'] != null) {
      StateError('Failed to create index $result');
    }
  }
}
