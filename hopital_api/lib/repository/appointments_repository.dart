import 'package:hopital_api/models/appointments.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('AppointmentsRepository');

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

  // Create a new Appointment Doctor or Package checkup
  Future<Appointments> createAppointment(Appointments appointment) async {
    final doc = appointment.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert appointment: ${result.errmsg}');
      throw StateError(
        'Failed to insert appointment: ${result.writeError?.errmsg ?? "Unknown error"}',
      );
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Appointments.fromJson(doc);
  }

  // Find Appointment by ID when user want to see appointment detail
  Future<Appointments?> findById(String id) async {
    final doc = await _collection.findOne(where.id(ObjectId.fromHexString(id)));
    if (doc == null) return null;
    return Appointments.fromJson(doc);
  }

  // Get Doctor Appointments where packageId is null
  Future<List<Appointments>> getDoctorAppointments({
    required String patientId,
    int limit = 20,
    int skip = 0,
  }) async {
    final selector = where
        .eq('patientId', ObjectId.fromHexString(patientId))
        .and(where.eq('packageId', null))
        .sortBy('createdAt', descending: true)
        .skip(skip)
        .limit(limit);

    final cursor = _collection.find(selector);
    final docs = await cursor.toList();
    return docs.map(Appointments.fromJson).toList();
  }

  // Get Package History where packageId is NOT null
  Future<List<Appointments>> getPackageHistory({
    required String patientId,
    int limit = 20,
    int skip = 0,
  }) async {
    final selector = where
        .eq('patientId', ObjectId.fromHexString(patientId))
        .and(where.ne('packageId', null))
        .sortBy('createdAt', descending: true)
        .skip(skip)
        .limit(limit);

    final cursor = _collection.find(selector);
    final docs = await cursor.toList();
    return docs.map(Appointments.fromJson).toList();
  }

  // Get All Appointments for a Patient
  Future<List<Appointments>> getAllByPatientId({
    required String patientId,
    int limit = 20,
    int skip = 0,
  }) async {
    final selector = where
        .eq('patientId', ObjectId.fromHexString(patientId))
        .sortBy('createdAt', descending: true)
        .skip(skip)
        .limit(limit);

    final cursor = _collection.find(selector);
    final docs = await cursor.toList();
    return docs.map(Appointments.fromJson).toList();
  }
}
