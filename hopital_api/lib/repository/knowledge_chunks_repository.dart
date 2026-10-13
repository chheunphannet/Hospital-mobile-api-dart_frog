import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';

class KnowledgeChunksRepository {
  KnowledgeChunksRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'sourceType': 1,
            'sourceId': 1,
          },
          'name': 'idx_knowledge_source',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }

    await createVectorIndex();
  }

  Future<void> createVectorIndex() async {
    try {
      final result = await _collection.db.runCommand({
        'createSearchIndexes': _collection.collectionName,
        'indexes': [
          {
            'name': 'vector_index',
            'type': 'vectorSearch',
            'definition': {
              'fields': [
                {
                  'type': 'vector',
                  'path': 'embedding',
                  'numDimensions': 768, // Index for Gemini (768 dimensions)
                  'similarity': 'cosine',
                },
                {
                  'type': 'filter',
                  'path': 'sourceType',
                },
                {
                  'type': 'filter',
                  'path': 'metadata.clinic',
                },
              ],
            },
          },
        ],
      });

      if (result['ok'] != 1) {
        log('Vector search index response: $result');
      }
    } catch (e) {
      log('Vector search index note: $e');
    }
  }

  Future<void> createIndexes() => createIndex();
}
