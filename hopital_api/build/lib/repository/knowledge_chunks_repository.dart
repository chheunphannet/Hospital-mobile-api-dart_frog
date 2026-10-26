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
            'type':
                'vectorSearch', //enables k-Nearest Neighbor (kNN) mathematical calculations on AI embeddings
            'definition': {
              'fields': [
                {
                  'type': 'vector',
                  'path': 'embedding', // [0.0124, -0.0452, 0.0891, ...]
                  'numDimensions':
                      768, // Gemini converts any sentence into a list of exactly 768 numbers.
                  'similarity':
                      'cosine', // Cosine similarity measures the angle of meaning between two sentences, not just matching words.
                },
                {
                  'type':
                      'filter', // Enables pre-filtering before doing AI vector search
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
