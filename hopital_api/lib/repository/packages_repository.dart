import 'package:mongo_dart/mongo_dart.dart';

class PackagesRepository {
  PackagesRepository(this._collection);

  final DbCollection _collection;

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {
            'metadata.supportedBranchIds': 1,
            'isActive': 1,
          },
          'name': 'idx_packages_branch_active',
        },
      ],
    });

    if (result['ok'] != 1) {
      throw StateError('Failed to create index: $result');
    }
  }

  Future<void> createIndexes() => createIndex();
}
