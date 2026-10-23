import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:logging/logging.dart';

Middleware exceptionHandler() {
  final _log = Logger('exceptionHandler');
  return (handler) {
    return (context) async {
      try {
        return await handler(context);
      } on AppException catch (e) {
        return _error(e.statusCode, e.code, e.message);
      } on FormatException {
        return _error(
          HttpStatus.badRequest,
          'INVALID_JSON',
          'Invalid request body',
        );
      } catch (e, st) {
        // Log the real error, but never send details to the client
        _log.severe('Unhandled: $e\n$st');
        return _error(
          HttpStatus.internalServerError,
          'INTERNAL_ERROR',
          'Something went wrong',
        );
      }
    };
  };
}

Response _error(int statusCode, String code, String message) {
  return Response.json(
    statusCode: statusCode,
    body: {
      'error': {'code': code, 'message': message},
    },
  );
}
