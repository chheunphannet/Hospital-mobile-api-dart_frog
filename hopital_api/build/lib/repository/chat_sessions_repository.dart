import 'package:mongo_dart/mongo_dart.dart';

class ChatSessionsRepository {
  ChatSessionsRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'patientId': 1,
            'lastInteractionAt': -1,
          },
          'name': 'idx_chat_patient_recent',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();
}
