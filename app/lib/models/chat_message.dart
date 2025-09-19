import 'rich_message_models.dart';

/// Chat message types for different kinds of messages
enum ChatMessageType {
  normal,
  welcome,
  analysis,
  loading,
  error,
  form,
  rich, // New type for rich content messages
}

/// Chat message model for the Chat screen
class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? formData;
  final Map<String, dynamic>? analysisData;
  final ChatMessageType messageType;
  final DateTime timestamp;
  final RichMessageContent? richContent;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.formData,
    this.analysisData,
    this.messageType = ChatMessageType.normal,
    DateTime? timestamp,
    this.richContent,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create rich message from content
  ChatMessage.rich({
    required RichMessageContent content,
    required this.isUser,
    DateTime? timestamp,
  })  : text = content.text ?? '',
        richContent = content,
        formData = null,
        analysisData = null,
        messageType = ChatMessageType.rich,
        timestamp = timestamp ?? DateTime.now();

  /// Create regular text message
  ChatMessage.text({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.messageType = ChatMessageType.normal,
  })  : richContent = null,
        formData = null,
        analysisData = null,
        timestamp = timestamp ?? DateTime.now();

  bool get hasForm => formData != null;
  bool get hasAnalysis => analysisData != null;
  bool get hasRichContent => richContent != null;
  bool get hasDashboardItems => richContent?.hasDashboardItems ?? false;
  bool get isSystemMessage => !isUser;
  bool get isWelcome => messageType == ChatMessageType.welcome;
  bool get isAnalysis => messageType == ChatMessageType.analysis;
  bool get isLoading => messageType == ChatMessageType.loading;
  bool get isError => messageType == ChatMessageType.error;
  bool get isRich => messageType == ChatMessageType.rich;

  /// Get display text (from rich content if available)
  String get displayText {
    if (hasRichContent && richContent!.text?.isNotEmpty == true) {
      return richContent!.text!;
    }
    return text;
  }

  /// Get dashboard items if available
  List<DashboardItem> get dashboardItems => richContent?.dashboardItems ?? [];
}
