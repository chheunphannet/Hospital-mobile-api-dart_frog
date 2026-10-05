import 'package:dotenv/dotenv.dart';

class Env {
  static final DotEnv _dotEnv = DotEnv()..load();

  static void init() {
    final requiredKeys = [
      'MONGO_URL',
      // 'DB_PASSWORD',
      // 'DB_HOST',
      // 'DB_PORT',
      // 'DB_NAME',
      // 'DB_USER',
      // 'JWT_SECRET',
    ];

    final missingKeys = requiredKeys.where((k) => _dotEnv[k] == null).toList();

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing required .env: ${missingKeys.join(', ')}',
      );
    }
  }

  static String get mongoUrl => _dotEnv['MONGO_URL']!;
}
