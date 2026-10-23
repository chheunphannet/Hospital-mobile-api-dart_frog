import 'package:dart_frog/dart_frog.dart';
import '../lib/middleware/exception_handler.dart';

Handler middleware(Handler handler) {
  return handler.use(exceptionHandler());
}
