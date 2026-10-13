import 'package:mongo_dart/mongo_dart.dart';

class FeedbacksRepository {
  FeedbacksRepository(this._collection);

  final DbCollection _collection;

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
}
