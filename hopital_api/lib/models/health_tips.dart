class HealthTips {
  final String? id;
  final String title;
  final String clinic;
  final String posterUrl;
  final bool isPopular;
  final int viewCount;
  final DateTime publishedAt;
  final List<ContentBlock> contentBlocks;

  const HealthTips({
    required this.title,
    required this.clinic,
    required this.posterUrl,
    required this.isPopular,
    required this.viewCount,
    required this.publishedAt,
    required this.contentBlocks,
    this.id,
  });

  factory HealthTips.fromJson(Map<String, dynamic> json) => HealthTips(
    id: json['id'] as String?,
    title: json['title'] as String,
    clinic: json['clinic'] as String,
    posterUrl: json['posterUrl'] as String,
    isPopular: json['isPopular'] as bool,
    viewCount: json['viewCount'] as int,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    contentBlocks: (json['contentBlocks'] as List)
        .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'clinic': clinic,
    'posterUrl': posterUrl,
    'isPopular': isPopular,
    'viewCount': viewCount,
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
