import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/middleware/exception_handler.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(exceptionHandler());
}
