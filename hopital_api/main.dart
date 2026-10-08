import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/repository/refresh_token_repository.dart';
import 'package:hopital_api/repository/users_repository.dart';
import 'package:hopital_api/service/mongo_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Env.init();
  final mongoService = await MongoService.connect(Env.mongoUrl);

  //users
  final usersRepo = UsersRepository(mongoService.collection('users'));
  await usersRepo.createIndex();

  //RefreshTokens
  final refreshRepo = RefreshTokenRepository(
    mongoService.collection('refresh_token'),
  );
  await refreshRepo.createIndex();
  return serve(
    handler
        .use(provider<UsersRepository>((_) => usersRepo))
        .use(provider<RefreshTokenRepository>((_) => refreshRepo)),
    ip,
    port,
  );
}
