import 'package:intl/intl.dart';

/// Message status enumeration
enum MessageStatus {
  sending,
  sent,
  delivered,
  failed;

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}

/// Message type enumeration
enum MessageType {
  text,
  voice,
  image;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.voice:
        return 'Voice';
      case MessageType.image:
        return 'Image';
    }
  }
}

/// Message sender enumeration
enum MessageSender {
  user,
  agent;

  String get displayName {
    switch (this) {
      case MessageSender.user:
        return 'User';
      case MessageSender.agent:
        return 'AI Agent';
    }
  }
}

/// Core Message model for chat interface
class Message {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType messageType;
  final String? agentType;
  final String language;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.messageType = MessageType.text,
    this.agentType,
    this.language = 'en',
    this.metadata,
  });

  /// Create a user message
  factory Message.user({
    required String id,
    required String content,
    MessageType messageType = MessageType.text,
    MessageStatus status = MessageStatus.sending,
    String language = 'en',
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: status,
      messageType: messageType,
      language: language,
      metadata: metadata,
    );
  }

  /// Create an agent message
  factory Message.agent({
    required String id,
    required String content,
    String? agentType,
    MessageType messageType = MessageType.text,
    String language = 'en',
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      content: content,
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
      messageType: messageType,
      agentType: agentType,
      language: language,
      metadata: metadata,
    );
  }

  /// Copy with new properties
  Message copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? messageType,
    String? agentType,
    String? language,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      messageType: messageType ?? this.messageType,
      agentType: agentType ?? this.agentType,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if message is from user
  bool get isFromUser => sender == MessageSender.user;

  /// Check if message is from agent
  bool get isFromAgent => sender == MessageSender.agent;

  /// Check if message is a text message
  bool get isTextMessage => messageType == MessageType.text;

  /// Check if message is a voice message
  bool get isVoiceMessage => messageType == MessageType.voice;

  /// Check if message is an image message
  bool get isImageMessage => messageType == MessageType.image;

  /// Check if message is currently sending
  bool get isSending => status == MessageStatus.sending;

  /// Check if message failed to send
  bool get isFailed => status == MessageStatus.failed;

  /// Get formatted timestamp
  String get formattedTime => DateFormat.Hm().format(timestamp);

  /// Get formatted date
  String get formattedDate => DateFormat.yMd().format(timestamp);

  /// Get formatted full date and time
  String get formattedDateTime => DateFormat.yMd().add_jm().format(timestamp);

  /// Convert to JSON for API communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'message_type': messageType.name,
      'sender_type': sender.name, // Map to database field
      'language': language,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == (json['sender'] ?? json['sender_type']),
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['message_type'],
        orElse: () => MessageType.text,
      ),
      agentType:
          json['agent_type'] as String?, // Keep for backward compatibility
      language: json['language'] as String? ?? 'en',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, content: $content, sender: $sender, timestamp: $timestamp)';
  }
}

/// Chat session model for conversation management
class ChatSession {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime lastActivity;
  final String? currentTopic;
  final Map<String, dynamic>? context;
  final List<String> recentMessages;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastActivity,
    this.currentTopic,
    this.context,
    this.recentMessages = const [],
  });

  /// Copy with new properties
  ChatSession copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? lastActivity,
    String? currentTopic,
    Map<String, dynamic>? context,
    List<String>? recentMessages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      currentTopic: currentTopic ?? this.currentTopic,
      context: context ?? this.context,
      recentMessages: recentMessages ?? this.recentMessages,
    );
  }

  /// Convert to JSON for API communication
  Map<String, dynamic> toJson() {
    return {
      'session_id': id,
      'recent_messages': recentMessages,
      'current_topic': currentTopic,
    };
  }

  /// Create from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActivity: DateTime.parse(json['last_activity'] as String),
      currentTopic: json['current_topic'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      recentMessages: (json['recent_messages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, topic: $currentTopic)';
  }
}
