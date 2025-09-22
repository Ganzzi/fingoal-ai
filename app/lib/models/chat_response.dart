import 'package:flutter/foundation.dart';

/// Enhanced response model for Router Agent responses
class AgentResponse {
  final bool success;
  final String agent;
  final String responseType;
  final Map<String, dynamic> content;
  final List<String> suggestedActions;
  final bool memoryUpdated;
  final Map<String, dynamic> meta;
  final String? error;

  const AgentResponse({
    required this.success,
    required this.agent,
    required this.responseType,
    required this.content,
    required this.suggestedActions,
    required this.memoryUpdated,
    required this.meta,
    this.error,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      success: json['success'] as bool? ?? false,
      agent: json['agent'] as String? ?? '',
      responseType: json['response_type'] as String? ?? 'unknown',
      content: json['content'] as Map<String, dynamic>? ?? {},
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      memoryUpdated: json['memory_updated'] as bool? ?? false,
      meta: json['meta'] as Map<String, dynamic>? ?? {},
      error: json['error'] as String?,
    );
  }

  /// Get detected intent from content
  String? get detectedIntent {
    return content['detected_intent'] as String?;
  }

  /// Get session identification info
  Map<String, dynamic>? get sessionIdentification {
    return content['session_identification'] as Map<String, dynamic>?;
  }

  /// Check if user is in active session
  bool get inActiveSession {
    final sessionInfo = sessionIdentification;
    return sessionInfo?['in_active_session'] as bool? ?? false;
  }

  /// Get active session type
  String? get sessionType {
    final sessionInfo = sessionIdentification;
    return sessionInfo?['session_type'] as String?;
  }

  /// Get analysis data
  Map<String, dynamic>? get analysis {
    return content['analysis'] as Map<String, dynamic>?;
  }

  /// Get processing time in milliseconds
  int? get processingTimeMs {
    return meta['processing_time_ms'] as int?;
  }

  /// Get session ID
  String? get sessionId {
    return meta['session_id'] as String?;
  }

  /// Get timestamp
  DateTime? get timestamp {
    final timestampStr = meta['timestamp'] as String?;
    if (timestampStr != null) {
      try {
        return DateTime.parse(timestampStr);
      } catch (e) {
        debugPrint('Failed to parse timestamp: $timestampStr');
      }
    }
    return null;
  }
}

/// Response model for text content with rich formatting
class TextResponse {
  final String message;
  final List<Map<String, dynamic>> visualizations;
  final List<String> suggestedActions;
  final List<String> nextSteps;
  final List<String> educationalTips;
  final List<String> disclaimers;

  const TextResponse({
    required this.message,
    required this.visualizations,
    required this.suggestedActions,
    required this.nextSteps,
    required this.educationalTips,
    required this.disclaimers,
  });

  factory TextResponse.fromJson(Map<String, dynamic> json) {
    return TextResponse(
      message: json['message'] as String? ?? '',
      visualizations: (json['visualizations'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      nextSteps: (json['next_steps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      educationalTips: (json['educational_tips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      disclaimers: (json['disclaimers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Check if response has any rich content
  bool get hasRichContent {
    return visualizations.isNotEmpty ||
        suggestedActions.isNotEmpty ||
        nextSteps.isNotEmpty ||
        educationalTips.isNotEmpty ||
        disclaimers.isNotEmpty;
  }
}

/// Response model for form-based interactions (future use)
class FormResponse {
  final String formId;
  final String title;
  final String description;
  final List<Map<String, dynamic>> fields;
  final Map<String, dynamic> validation;
  final String submitEndpoint;

  const FormResponse({
    required this.formId,
    required this.title,
    required this.description,
    required this.fields,
    required this.validation,
    required this.submitEndpoint,
  });

  factory FormResponse.fromJson(Map<String, dynamic> json) {
    return FormResponse(
      formId: json['form_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      validation: json['validation'] as Map<String, dynamic>? ?? {},
      submitEndpoint: json['submit_endpoint'] as String? ?? '',
    );
  }
}

/// Response model for analysis results with data visualizations
class AnalysisResponse {
  final String analysisType;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> charts;
  final List<String> insights;
  final List<String> recommendations;
  final double? confidenceScore;

  const AnalysisResponse({
    required this.analysisType,
    required this.data,
    required this.charts,
    required this.insights,
    required this.recommendations,
    this.confidenceScore,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      analysisType: json['analysis_type'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      charts: (json['charts'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      confidenceScore: json['confidence_score'] as double?,
    );
  }
}

/// Factory class for creating typed responses from AgentResponse
class ResponseFactory {
  /// Create a TextResponse from AgentResponse content
  static TextResponse? createTextResponse(AgentResponse agentResponse) {
    if (agentResponse.responseType == 'text' ||
        agentResponse.responseType == 'analysis') {
      try {
        return TextResponse.fromJson(agentResponse.content);
      } catch (e) {
        debugPrint('Failed to create TextResponse: $e');
        return null;
      }
    }
    return null;
  }

  /// Create a FormResponse from AgentResponse content
  static FormResponse? createFormResponse(AgentResponse agentResponse) {
    if (agentResponse.responseType == 'form') {
      try {
        return FormResponse.fromJson(agentResponse.content);
      } catch (e) {
        debugPrint('Failed to create FormResponse: $e');
        return null;
      }
    }
    return null;
  }

  /// Create an AnalysisResponse from AgentResponse content
  static AnalysisResponse? createAnalysisResponse(AgentResponse agentResponse) {
    if (agentResponse.responseType == 'analysis') {
      try {
        return AnalysisResponse.fromJson(agentResponse.content);
      } catch (e) {
        debugPrint('Failed to create AnalysisResponse: $e');
        return null;
      }
    }
    return null;
  }
}
