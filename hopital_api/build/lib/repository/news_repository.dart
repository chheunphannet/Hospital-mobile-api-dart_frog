import 'package:hopital_api/models/news.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class NewsRepository {
  NewsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('NewsRepository');

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'publishedAt': -1},
          'name': 'idx_news_published',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index $result');
    }
  }

  Future<void> createIndexes() => createIndex();

  Future<News> create(News news) async {
    final doc = news.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert news: ${result.errmsg}');
      final msg = result.writeError?.errmsg ?? 'Unknown error';
      throw StateError('Failed to insert news: $msg');
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return News.fromJson(doc);
  }

  Future<List<News>> getAll({int limit = 50, int skip = 0}) async {
    final cursor = _collection.find(
      where.sortBy('publishedAt', descending: true).skip(skip).limit(limit),
    );
    final docs = await cursor.toList();
    return docs.map(News.fromJson).toList();
  }

  Future<News?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return News.fromJson(doc);
  }
}
