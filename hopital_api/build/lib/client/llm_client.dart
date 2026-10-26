import 'dart:async';
import 'dart:convert';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ChatTurn {
  const ChatTurn({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class LlmClient {
  LlmClient({
    required this.apiKey,
    this.model = 'gemini-3.1-flash-lite',
    http.Client? client,
  }) : _http = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _http;

  static final _log = Logger('LlmClient');
  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  Future<String> generate({
    required String systemPrompt,
    required List<ChatTurn> history,
    double temperature = 0.3,
    int maxOutputTokens = 800,
  }) async {
    final http.Response res;
    try {
      res = await _http
          .post(
            Uri.parse('$_base/models/$model:generateContent'),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': systemPrompt},
                ],
              },
              'contents': [
                for (final t in history)
                  {
                    'role': t.isUser ? 'user' : 'model',
                    'parts': [
                      {'text': t.text},
                    ],
                  },
              ],
              'generationConfig': {
                'temperature': temperature,
                'maxOutputTokens': maxOutputTokens,
              },
            }),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      _log.warning('Gemini request timed out after 60s');
      throw const ExternalServiceException('AI assistant request timed out. Please try again.');
    }

    if (res.statusCode != 200) {
      _log.severe('Gemini failed ${res.statusCode}: ${res.body}');
      throw const ExternalServiceException();
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    final parts = candidates == null || candidates.isEmpty
        ? null
        : (candidates.first['content']?['parts'] as List?);

    if (parts == null || parts.isEmpty) {
      _log.warning('Gemini returned no text: ${res.body}');
      throw const ExternalServiceException('The assistant could not answer');
    }

    return parts.map((p) => p['text'] ?? '').join().trim();
  }
}
