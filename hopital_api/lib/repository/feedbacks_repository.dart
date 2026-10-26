import 'package:hopital_api/models/feedbacks.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class FeedbacksRepository {
  FeedbacksRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('FeedbacksRepository');

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'adminWorkflow.status': 1,
            'adminWorkflow.priority': 1,
          },
          'name': 'idx_feedbacks_admin_workflow',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();

  Future<Feedbacks> create(Feedbacks feedback) async {
    final doc = feedback.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert feedback: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert feedback: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Feedbacks.fromJson(doc);
  }

  Future<List<Feedbacks>> getAll({
    String? status,
    String? priority,
    int limit = 50,
    int skip = 0,
  }) async {
    final selector = where.sortBy('createdAt', descending: true);
    if (status != null && status.isNotEmpty) {
      selector.eq('adminWorkflow.status', status);
    }
    if (priority != null && priority.isNotEmpty) {
      selector.eq('adminWorkflow.priority', priority);
    }
    selector.skip(skip).limit(limit);

    final cursor = _collection.find(selector);
    final docs = await cursor.toList();
    return docs.map(Feedbacks.fromJson).toList();
  }

  Future<Feedbacks?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Feedbacks.fromJson(doc);
  }

  Future<List<Feedbacks>> findByPatientId(
    String patientId, {
    int limit = 20,
    int skip = 0,
  }) async {
    final oid = _toObjectId(patientId);
    final selector = where
        .eq('patientId', oid ?? patientId)
        .sortBy('createdAt', descending: true)
        .skip(skip)
        .limit(limit);

    final docs = await _collection.find(selector).toList();
    return docs.map(Feedbacks.fromJson).toList();
  }
}

ObjectId? _toObjectId(String? id) {
  if (id == null) return null;
  try {
    return ObjectId.fromHexString(id);
  } catch (_) {
    return null;
  }
}
