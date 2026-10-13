class KnowledgeChunks {
  final String? id;
  final String sourceType;
  final String sourceId;
  final ChunkMetadata metadata;
  final String content;
  final List<double> embedding;

  const KnowledgeChunks({
    required this.sourceType,
    required this.sourceId,
    required this.metadata,
    required this.content,
    required this.embedding,
    this.id,
  });

  factory KnowledgeChunks.fromJson(Map<String, dynamic> json) =>
      KnowledgeChunks(
    id: json['id'] as String?,
    sourceType: json['sourceType'] as String,
    sourceId: json['sourceId'] as String,
    metadata: ChunkMetadata.fromJson(
      json['metadata'] as Map<String, dynamic>,
    ),
    content: json['content'] as String,
    embedding: (json['embedding'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceType': sourceType,
    'sourceId': sourceId,
    'metadata': metadata.toJson(),
    'content': content,
    'embedding': embedding,
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
