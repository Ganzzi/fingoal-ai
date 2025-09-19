/// Models for Dynamic Form Rendering
///
/// These models define the JSON schema structure for form sections
/// that will be sent by the Intake Agent n8n workflow.

class FormSection {
  final String id;
  final String title;
  final List<String> recommendedProperties;
  final String inputType;
  final String? userInput;

  const FormSection({
    required this.id,
    required this.title,
    required this.recommendedProperties,
    required this.inputType,
    this.userInput,
  });

  factory FormSection.fromJson(Map<String, dynamic> json) {
    return FormSection(
      id: json['id'] as String,
      title: json['title'] as String,
      recommendedProperties:
          List<String>.from(json['recommendedProperties'] as List),
      inputType: json['inputType'] as String,
      userInput: json['userInput'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'recommendedProperties': recommendedProperties,
      'inputType': inputType,
      'userInput': userInput,
    };
  }

  FormSection copyWith({
    String? id,
    String? title,
    List<String>? recommendedProperties,
    String? inputType,
    String? userInput,
  }) {
    return FormSection(
      id: id ?? this.id,
      title: title ?? this.title,
      recommendedProperties:
          recommendedProperties ?? this.recommendedProperties,
      inputType: inputType ?? this.inputType,
      userInput: userInput ?? this.userInput,
    );
  }
}

class FormData {
  final List<FormSection> sections;

  const FormData({required this.sections});

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      sections: (json['sections'] as List)
          .map((section) =>
              FormSection.fromJson(section as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  /// Get form data with user inputs as a map
  Map<String, String> getUserInputs() {
    final Map<String, String> inputs = {};
    for (final section in sections) {
      if (section.userInput != null && section.userInput!.isNotEmpty) {
        inputs[section.id] = section.userInput!;
      }
    }
    return inputs;
  }

  /// Check if all sections have user input
  bool get isComplete {
    return sections.every((section) =>
        section.userInput != null && section.userInput!.trim().isNotEmpty);
  }
}
