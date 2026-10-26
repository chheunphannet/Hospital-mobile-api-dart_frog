import 'dart:convert';

import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class EmbeddingClient {
  EmbeddingClient({
    required this.apiKey,
    this.model = 'gemini-embedding-001',
    this.dimensions = 768,
    http.Client? client,
  }) : _http = client ?? http.Client();

  final String apiKey;
  final String model;
  final int dimensions; // must match numDimensions in your vector index
  final http.Client _http;

  static final _log = Logger('EmbeddingClient');
  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  Future<List<double>> embed(String text, {required EmbeddingTask task}) async {
    final res = await _http.post(
      Uri.parse('$_base/models/$model:embedContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'model': 'models/$model',
        'content': {
          'parts': [
            {'text': text},
          ],
        },
        'taskType': task == EmbeddingTask.document
            ? 'RETRIEVAL_DOCUMENT'
            : 'RETRIEVAL_QUERY',
        'outputDimensionality': dimensions,
      }),
    );

    if (res.statusCode != 200) {
      _log.severe('Embedding failed ${res.statusCode}: ${res.body}');
      throw const ExternalServiceException();
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final values = (data['embedding']['values'] as List).cast<num>();
    final vector = values.map((n) => n.toDouble()).toList();

    if (vector.length != dimensions) {
      throw StateError(
        'Embedding size ${vector.length} does not match index size $dimensions',
      );
    }
    return vector;
  }
}

enum EmbeddingTask { document, query }
