import 'package:mongo_dart/mongo_dart.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'patientId': 1,
            'status': 1,
            'createdAt': -1,
          },
          'name': 'idx_appointments_patient_history',
        },
        {
          'key': {
            'doctorId': 1,
            'scheduling.requestedDate': 1,
          },
          'name': 'idx_appointments_doctor_schedule',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();
}
