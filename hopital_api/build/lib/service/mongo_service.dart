import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';

class MongoService {
  MongoService(this._db);

  final Db _db;
  static final _log = Logger('MongoService');

  static Future<MongoService> connect(String url) async {
    final db = await Db.create(url);
    await db.open();
    _log.info('mongo db connection successfully!');

    return MongoService(db);
  }

  DbCollection collection(String name) => _db.collection(name);

  Future<void> close() async {
    await _db.close();
  }
}
