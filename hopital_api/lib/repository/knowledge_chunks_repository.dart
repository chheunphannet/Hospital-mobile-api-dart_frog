import 'package:hopital_api/models/knowledge_chunks.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class KnowledgeChunksRepository {
  KnowledgeChunksRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('KnowledgeChunksRepository');

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
                  'numDimensions': 768,
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
        _log.warning('Vector search index response: $result');
      }
    } catch (e) {
      _log.warning('Vector search index note: $e');
    }
  }

  Future<void> createIndexes() => createIndex();

  Future<void> deleteBySource(String sourceType, String sourceId) async {
    await _collection.deleteMany({
      'sourceType': sourceType,
      'sourceId': sourceId,
    });
  }

  Future<void> insert(KnowledgeChunks chunk) async {
    await _collection.insertOne(chunk.toJson());
  }

  Future<List<ChunkHit>> search({
    required List<double> queryEmbedding,
    int limit = 5,
    String? sourceType,
    String? clinic,
  }) async {
    final filter = <String, dynamic>{
      if (sourceType != null) 'sourceType': sourceType,
      if (clinic != null) 'metadata.clinic': clinic,
    };

    final pipeline = [
      {
        r'$vectorSearch': {
          'index': 'vector_index',
          'path': 'embedding',
          'queryVector': queryEmbedding,
          'numCandidates': limit * 20,
          'limit': limit,
          if (filter.isNotEmpty) 'filter': filter,
        },
      },
      {
        r'$project': {
          'embedding': 0,
          'searchScore': {r'$meta': 'vectorSearchScore'},
        },
      },
    ];

    final docs = await _collection.aggregateToStream(pipeline).toList();

    return docs.map((doc) {
      final score = (doc['searchScore'] as num).toDouble();
      doc.remove('searchScore');
      return ChunkHit(KnowledgeChunks.fromJson(doc), score);
    }).toList();
  }
}

class ChunkHit {
  const ChunkHit(this.chunk, this.score);
  final KnowledgeChunks chunk;
  final double score;
}
