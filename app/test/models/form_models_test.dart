import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/models/form_models.dart';

void main() {
  group('FormSection Tests', () {
    test('should create FormSection from JSON correctly', () {
      final json = {
        'id': 'money_accounts',
        'title': 'Money Accounts',
        'recommendedProperties': ['Bank Name', 'Account Type', 'Balance'],
        'inputType': 'text',
        'userInput': 'My test input'
      };

      final formSection = FormSection.fromJson(json);

      expect(formSection.id, equals('money_accounts'));
      expect(formSection.title, equals('Money Accounts'));
      expect(formSection.recommendedProperties,
          equals(['Bank Name', 'Account Type', 'Balance']));
      expect(formSection.inputType, equals('text'));
      expect(formSection.userInput, equals('My test input'));
    });

    test('should create FormSection from JSON without userInput', () {
      final json = {
        'id': 'debts',
        'title': 'Debts',
        'recommendedProperties': ['Creditor', 'Amount', 'Interest Rate'],
        'inputType': 'text'
      };

      final formSection = FormSection.fromJson(json);

      expect(formSection.id, equals('debts'));
      expect(formSection.title, equals('Debts'));
      expect(formSection.recommendedProperties,
          equals(['Creditor', 'Amount', 'Interest Rate']));
      expect(formSection.inputType, equals('text'));
      expect(formSection.userInput, isNull);
    });

    test('should convert FormSection to JSON correctly', () {
      const formSection = FormSection(
          id: 'insurance',
          title: 'Insurance',
          recommendedProperties: ['Provider', 'Type', 'Premium'],
          inputType: 'text',
          userInput: 'Test insurance data');

      final json = formSection.toJson();

      expect(json['id'], equals('insurance'));
      expect(json['title'], equals('Insurance'));
      expect(json['recommendedProperties'],
          equals(['Provider', 'Type', 'Premium']));
      expect(json['inputType'], equals('text'));
      expect(json['userInput'], equals('Test insurance data'));
    });

    test('should create copy with updated values', () {
      const original = FormSection(
        id: 'savings',
        title: 'Savings',
        recommendedProperties: ['Bank', 'Amount'],
        inputType: 'text',
      );

      final updated = original.copyWith(userInput: 'New user input data');

      expect(updated.id, equals('savings'));
      expect(updated.title, equals('Savings'));
      expect(updated.recommendedProperties, equals(['Bank', 'Amount']));
      expect(updated.inputType, equals('text'));
      expect(updated.userInput, equals('New user input data'));
      expect(original.userInput, isNull); // Original should be unchanged
    });
  });

  group('FormData Tests', () {
    test('should create FormData from JSON correctly', () {
      final json = {
        'sections': [
          {
            'id': 'money_accounts',
            'title': 'Money Accounts',
            'recommendedProperties': ['Bank Name', 'Account Type'],
            'inputType': 'text'
          },
          {
            'id': 'debts',
            'title': 'Debts',
            'recommendedProperties': ['Creditor', 'Amount'],
            'inputType': 'text'
          }
        ]
      };

      final formData = FormData.fromJson(json);

      expect(formData.sections.length, equals(2));
      expect(formData.sections[0].id, equals('money_accounts'));
      expect(formData.sections[1].id, equals('debts'));
    });

    test('should convert FormData to JSON correctly', () {
      const formData = FormData(sections: [
        FormSection(
            id: 'goals',
            title: 'Financial Goals',
            recommendedProperties: ['Goal Type', 'Target Amount'],
            inputType: 'text',
            userInput: 'Save for house')
      ]);

      final json = formData.toJson();

      expect(json['sections'], isA<List>());
      expect((json['sections'] as List).length, equals(1));
      expect(json['sections'][0]['id'], equals('goals'));
      expect(json['sections'][0]['userInput'], equals('Save for house'));
    });

    test('should get user inputs as map', () {
      const formData = FormData(sections: [
        FormSection(
            id: 'money_accounts',
            title: 'Money Accounts',
            recommendedProperties: ['Bank Name'],
            inputType: 'text',
            userInput: r'Chase Checking, $5000'),
        FormSection(
            id: 'debts',
            title: 'Debts',
            recommendedProperties: ['Creditor'],
            inputType: 'text',
            userInput: r'Credit Card, $2000'),
        FormSection(
            id: 'empty_section',
            title: 'Empty Section',
            recommendedProperties: [],
            inputType: 'text',
            userInput: null)
      ]);

      final userInputs = formData.getUserInputs();

      expect(userInputs.length, equals(2));
      expect(userInputs['money_accounts'], equals(r'Chase Checking, $5000'));
      expect(userInputs['debts'], equals(r'Credit Card, $2000'));
      expect(userInputs.containsKey('empty_section'), isFalse);
    });

    test('should check if form is complete', () {
      const incompleteForm = FormData(sections: [
        FormSection(
            id: 'section1',
            title: 'Section 1',
            recommendedProperties: [],
            inputType: 'text',
            userInput: 'Has input'),
        FormSection(
            id: 'section2',
            title: 'Section 2',
            recommendedProperties: [],
            inputType: 'text',
            userInput: null)
      ]);

      const completeForm = FormData(sections: [
        FormSection(
            id: 'section1',
            title: 'Section 1',
            recommendedProperties: [],
            inputType: 'text',
            userInput: 'Has input'),
        FormSection(
            id: 'section2',
            title: 'Section 2',
            recommendedProperties: [],
            inputType: 'text',
            userInput: 'Also has input')
      ]);

      expect(incompleteForm.isComplete, isFalse);
      expect(completeForm.isComplete, isTrue);
    });

    test('should handle empty string as incomplete', () {
      const formData = FormData(sections: [
        FormSection(
            id: 'section1',
            title: 'Section 1',
            recommendedProperties: [],
            inputType: 'text',
            userInput: '   ' // Only whitespace
            )
      ]);

      expect(formData.isComplete, isFalse);
    });
  });
}
