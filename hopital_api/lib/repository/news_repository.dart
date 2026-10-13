import 'package:mongo_dart/mongo_dart.dart';

class NewsRepository {
  NewsRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'publishedAt': -1,
          }, //(-1) Descending MongoDB stores the dates already sorted
          'name': 'idx_news_published',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();
}
