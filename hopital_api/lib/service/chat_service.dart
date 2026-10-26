import 'package:hopital_api/client/embedding_client.dart';
import 'package:hopital_api/client/llm_client.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/repository/knowledge_chunks_repository.dart';
import 'package:hopital_api/services/chat_prompt.dart';

class ChatResponse {
  final String reply;
  final bool isEmergency;
  final List<ChatSource> sources;

  const ChatResponse({
    required this.reply,
    this.isEmergency = false,
    this.sources = const [],
  });

  Map<String, dynamic> toJson() => {
    'reply': reply,
    'isEmergency': isEmergency,
    'sources': sources.map((s) => s.toJson()).toList(),
  };
}

class ChatSource {
  final String sourceType;
  final String sourceId;
  final String title;
  final double score;

  const ChatSource({
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'sourceType': sourceType,
    'sourceId': sourceId,
    'title': title,
    'score': score,
  };
}

class ChatService {
  final EmbeddingClient _embedder;
  final KnowledgeChunksRepository _chunks;
  final LlmClient _llm;

  const ChatService({
    required EmbeddingClient embedder,
    required KnowledgeChunksRepository chunks,
    required LlmClient llm,
  }) : _embedder = embedder,
       _chunks = chunks,
       _llm = llm;

  static final _emergencyPatterns = [
    RegExp(
      r'\b(chest pain|heart attack|cardiac arrest)\b',
      caseSensitive: false,
    ),
    RegExp(
      r"\b(can('t|not)? breathe|difficulty breathing|shortness of breath|choking)\b",
      caseSensitive: false,
    ),
    RegExp(
      r'\b(unconscious|passed out|fainted|seizure|convulsion)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(heavy bleeding|severe bleeding|coughing blood)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(stroke|sudden numbness|facial droop|slurred speech)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(poison|poisoning|overdose)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(emergency|urgent assistance|ambulance)\b',
      caseSensitive: false,
    ),
  ];

  static bool isEmergencyQuery(String query) {
    return _emergencyPatterns.any((p) => p.hasMatch(query));
  }

  Future<ChatResponse> answerPublicQuery({
    required String message,
    List<ChatTurn> history = const [],
  }) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      throw const ValidationException('Message cannot be empty');
    }

    if (isEmergencyQuery(cleanMessage)) {
      return const ChatResponse(
        reply:
            'If you or someone nearby is experiencing a medical emergency, please call our 24/7 Emergency Hotline immediately at 081 811 789 or 078 233 789, or proceed directly to the nearest Orienda Emergency Room (Steung Meanchey / Chamkarmon).',
        isEmergency: true,
      );
    }

    final queryVector = await _embedder.embed(
      cleanMessage,
      task: EmbeddingTask.query,
    );
    final hits = await _chunks.search(queryEmbedding: queryVector, limit: 4);
    final relevantHits = hits.where((h) => h.score >= 0.795).toList();

    final knowledgeText = relevantHits.isNotEmpty
        ? relevantHits.map((h) => h.chunk.content).join('\n---\n')
        : ChatPrompt.noContext;

    final systemPrompt = ChatPrompt.system(knowledgeText);

    final turns = <ChatTurn>[
      for (final t in history)
        if (t.text.trim().isNotEmpty) t,
      ChatTurn(isUser: true, text: cleanMessage),
    ];

    final reply = await _llm.generate(
      systemPrompt: systemPrompt,
      history: turns,
    );

    return ChatResponse(
      reply: reply,
      isEmergency: false,
      sources: relevantHits
          .map(
            (h) => ChatSource(
              sourceType: h.chunk.sourceType,
              sourceId: h.chunk.sourceId,
              title: h.chunk.metadata.title,
              score: double.parse(h.score.toStringAsFixed(3)),
            ),
          )
          .toList(),
    );
  }
}
