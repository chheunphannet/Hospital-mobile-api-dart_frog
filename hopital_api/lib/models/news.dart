class News {
  final String? id;
  final String title;
  final String posterUrl;
  final DateTime publishedAt;
  final List<ContentBlock> contentBlocks;

  const News({
    required this.title,
    required this.posterUrl,
    required this.publishedAt,
    required this.contentBlocks,
    this.id,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json['id'] as String?,
    title: json['title'] as String,
    posterUrl: json['posterUrl'] as String,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    contentBlocks: (json['contentBlocks'] as List)
        .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'posterUrl': posterUrl,
    'publishedAt': publishedAt.toIso8601String(),
    'contentBlocks': contentBlocks.map((e) => e.toJson()).toList(),
  };
}

class ContentBlock {
  final String imageUrl;
  final String caption;
  final String text;

  const ContentBlock({
    required this.imageUrl,
    required this.caption,
    required this.text,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) => ContentBlock(
    imageUrl: json['imageUrl'] as String,
    caption: json['caption'] as String,
    text: json['text'] as String,
  );

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'caption': caption,
    'text': text,
  };
}
