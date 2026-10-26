class ChatSessions {
  final String? id;
  final String patientId;
  final DateTime startedAt;
  final DateTime lastInteractionAt;
  final List<ChatMessage> messages;

  const ChatSessions({
    required this.patientId,
    required this.startedAt,
    required this.lastInteractionAt,
    required this.messages,
    this.id,
  });

  factory ChatSessions.fromJson(Map<String, dynamic> json) => ChatSessions(
    id: json['id'] as String?,
    patientId: json['patientId'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    lastInteractionAt: DateTime.parse(json['lastInteractionAt'] as String),
    messages: (json['messages'] as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'startedAt': startedAt.toIso8601String(),
    'lastInteractionAt': lastInteractionAt.toIso8601String(),
    'messages': messages.map((e) => e.toJson()).toList(),
  };
}

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final SuggestedAction? suggestedAction;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestedAction,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    sender: json['sender'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    suggestedAction: json['suggestedAction'] != null
        ? SuggestedAction.fromJson(
            json['suggestedAction'] as Map<String, dynamic>,
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'suggestedAction': suggestedAction?.toJson(),
  };
}

class SuggestedAction {
  final String type;
  final String? targetId;

  const SuggestedAction({
    required this.type,
    this.targetId,
  });

  factory SuggestedAction.fromJson(Map<String, dynamic> json) =>
      SuggestedAction(
        type: json['type'] as String,
        targetId: json['targetId'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'type': type,
    'targetId': targetId,
  };
}
