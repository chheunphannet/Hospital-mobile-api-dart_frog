import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

class Env {
  static final DotEnv _dotEnv = DotEnv()..load();
  static final _log = Logger('Env');
  static void init() {
    final requiredKeys = [
      'MONGO_URL',
      'JWT_ACCESS_SECRET',
      'JWT_REFRESH_SECRET',
      'ACCESS_TOKEN_TTL',
      'REFRESH_TOKEN_TTL',
      'IS_PROD',
      'GOOGLE_CLIENT_ID',
      'GEMINI_API_KEY',
      'RUN_INGEST',
      'GEMINI_MODEL',
      // 'DB_PASSWORD',
      // 'DB_HOST',
      // 'DB_PORT',
      // 'DB_NAME',
      // 'DB_USER',
      // 'JWT_SECRET',
    ];

    final missingKeys = requiredKeys.where((k) => _dotEnv[k] == null).toList();

    if (missingKeys.isNotEmpty) {
      _log.severe('Missing required .env: ${missingKeys.join(', ')}');
      throw Exception(
        'Missing required .env: ${missingKeys.join(', ')}',
      );
    }
  }

  static String get mongoUrl => _dotEnv['MONGO_URL']!;
  static String get jwtAccessTokenSecret => _dotEnv['JWT_ACCESS_SECRET']!;
  static String get jwtRefreshTokenSecret => _dotEnv['JWT_REFRESH_SECRET']!;
  static int get accessTokenTTL => int.parse(_dotEnv['ACCESS_TOKEN_TTL']!);
  static int get refreshTokenTTL => int.parse(_dotEnv['REFRESH_TOKEN_TTL']!);
  static String get isProd => _dotEnv['IS_PROD']!;
  static String get googleClientId => _dotEnv['GOOGLE_CLIENT_ID']!;
  static String get geminiApiKey => _dotEnv['GEMINI_API_KEY']!;
  static String get runIngest => _dotEnv['RUN_INGEST']!;
  static String get geminiModel => _dotEnv['GEMINI_MODEL']!;
}
