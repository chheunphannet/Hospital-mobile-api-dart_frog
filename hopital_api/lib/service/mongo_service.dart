import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  MongoService(this._db);

  final Db _db;

  static Future<MongoService> connect(String url) async {
    final db = await Db.create(url);
    await db.open();
    print("mongo db connection successfully!");

    return MongoService(db);
  }

  DbCollection collection(String name) => _db.collection(name);

  Future<void> close() async {
    await _db.close();
  }
}
