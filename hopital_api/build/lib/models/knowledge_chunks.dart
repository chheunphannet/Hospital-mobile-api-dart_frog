import 'package:mongo_dart/mongo_dart.dart';

class KnowledgeChunks {
  final String? id;
  final String sourceType;
  final String sourceId;
  final ChunkMetadata metadata;
  final String content;
  final double? score;
  final List<double> embedding;

  const KnowledgeChunks({
    required this.sourceType,
    required this.sourceId,
    required this.metadata,
    required this.content,
    required this.embedding,
    this.id,
    this.score,
  });

  factory KnowledgeChunks.fromJson(Map<String, dynamic> json) =>
      KnowledgeChunks(
        id: json['_id'] != null
            ? (json['_id'] is ObjectId
                ? (json['_id'] as ObjectId).oid
                : json['_id'].toString())
            : (json['id'] as String?),
        sourceType: json['sourceType'] as String,
        sourceId: json['sourceId'] as String,
        metadata: ChunkMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>,
        ),
        content: json['content'] as String,
        embedding: (json['embedding'] as List?)
                ?.map((n) => (n as num).toDouble())
                .toList() ??
            const [],
        score: (json['score'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': ObjectId.fromHexString(id!),
    'sourceType': sourceType,
    'sourceId': sourceId,
    'metadata': metadata.toJson(),
    'content': content,
    'embedding': embedding,
    if (score != null) 'score': score,
  };
}

class ChunkMetadata {
  final String title;
  final String clinic;
  final List<String> branches;
  final List<String> tags;

  const ChunkMetadata({
    required this.title,
    required this.clinic,
    required this.branches,
    required this.tags,
  });

  factory ChunkMetadata.fromJson(Map<String, dynamic> json) => ChunkMetadata(
    title: json['title'] as String,
    clinic: json['clinic'] as String,
    branches: (json['branches'] as List).map((e) => e as String).toList(),
    tags: (json['tags'] as List).map((e) => e as String).toList(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'clinic': clinic,
    'branches': branches,
    'tags': tags,
  };
}
