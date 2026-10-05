import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/config/env.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Env.init();

  return serve(handler, ip, port);
}
