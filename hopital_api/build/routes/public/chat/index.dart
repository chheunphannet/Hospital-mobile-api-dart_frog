import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/client/llm_client.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/service/chat_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final message = body['message'] as String?;
  if (message == null || message.trim().isEmpty) {
    throw const ValidationException('Field "message" is required');
  }

  final rawHistory = body['history'] as List<dynamic>?;
  final history = <ChatTurn>[];
  if (rawHistory != null) {
    for (final item in rawHistory) {
      if (item is Map<String, dynamic>) {
        final isUser = item['isUser'] as bool? ?? true;
        final text = item['text'] as String? ?? '';
        if (text.isNotEmpty) {
          history.add(ChatTurn(isUser: isUser, text: text));
        }
      }
    }
  }

  final chatService = context.read<ChatService>();
  final response = await chatService.answerPublicQuery(
    message: message,
    history: history,
  );

  return Response.json(body: response.toJson());
}
