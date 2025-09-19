import 'package:flutter/material.dart';
import '../models/form_models.dart';

/// Dynamic Form Widget that renders form sections from JSON payload
///
/// This widget accepts a JSON object and renders interactive form sections
/// for onboarding questions sent by the AI Intake Agent.
class DynamicFormWidget extends StatefulWidget {
  final Map<String, dynamic> formJson;
  final Function(Map<String, String>) onFormSubmit;
  final VoidCallback? onFormChanged;

  const DynamicFormWidget({
    super.key,
    required this.formJson,
    required this.onFormSubmit,
    this.onFormChanged,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  late FormData _formData;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    try {
      _formData = FormData.fromJson(widget.formJson);

      // Initialize controllers and focus nodes for each section
      for (final section in _formData.sections) {
        _controllers[section.id] =
            TextEditingController(text: section.userInput ?? '');
        _focusNodes[section.id] = FocusNode();

        // Add listener to update form data when text changes
        _controllers[section.id]!.addListener(() {
          _updateSectionInput(section.id, _controllers[section.id]!.text);
        });
      }

      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error parsing form data: ${e.toString()}';
      });
    }
  }

  void _updateSectionInput(String sectionId, String input) {
    final sectionIndex =
        _formData.sections.indexWhere((s) => s.id == sectionId);
    if (sectionIndex != -1) {
      final updatedSection =
          _formData.sections[sectionIndex].copyWith(userInput: input);
      final updatedSections = List<FormSection>.from(_formData.sections);
      updatedSections[sectionIndex] = updatedSection;

      setState(() {
        _formData = FormData(sections: updatedSections);
      });

      widget.onFormChanged?.call();
    }
  }

  void _handleSubmit() {
    // Validate that all sections have input
    bool hasEmptyFields = false;
    for (final section in _formData.sections) {
      if (section.userInput == null || section.userInput!.trim().isEmpty) {
        hasEmptyFields = true;
        break;
      }
    }

    if (hasEmptyFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all sections before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Submit the form data
    final userInputs = _formData.getUserInputs();
    widget.onFormSubmit(userInputs);
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return _buildFormContent();
  }

  Widget _buildErrorWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Form Error',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form sections
            ..._formData.sections.map((section) => _FormSectionWidget(
                  section: section,
                  controller: _controllers[section.id]!,
                  focusNode: _focusNodes[section.id]!,
                )),

            const SizedBox(height: 24),

            // Submit button
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual form section widget
class _FormSectionWidget extends StatelessWidget {
  final FormSection section;
  final TextEditingController controller;
  final FocusNode focusNode;

  const _FormSectionWidget({
    required this.section,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          // Recommended properties (read-only)
          if (section.recommendedProperties.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested information to include:',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...section.recommendedProperties.map((property) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                property,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // User input field
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Please provide your ${section.title.toLowerCase()} information...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: colorScheme.outline.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.all(12),
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}
