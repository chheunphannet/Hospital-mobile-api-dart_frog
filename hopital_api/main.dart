import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/service/mongo_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Env.init();
  final mongoService = await MongoService.connect(Env.mongoUrl);

  return serve(handler, ip, port);
}
