import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutormate/features/auth/domain/models/user_role.dart';
import 'package:tutormate/features/job_request/domain/models/job_request_model.dart';
import 'package:tutormate/features/job_request/domain/models/tutor_interest_model.dart';
import 'package:tutormate/shared/widgets/app_button.dart';
import 'package:tutormate/shared/widgets/app_text_field.dart';
import 'package:tutormate/shared/widgets/app_dropdown.dart';

void main() {
  group('Domain Model Unit Tests', () {
    test('UserRole.fromString maps role strings correctly', () {
      expect(UserRole.fromString('student'), UserRole.studentGuardian);
      expect(UserRole.fromString('parent'), UserRole.studentGuardian);
      expect(UserRole.fromString('tutor'), UserRole.tutor);
      expect(UserRole.fromString(null), isNull);
    });

    test('JobRequestStatus and TutorInterestStatus parsing', () {
      expect(JobRequestStatus.fromString('open'), JobRequestStatus.open);
      expect(JobRequestStatus.fromString('accepted'), JobRequestStatus.accepted);
      expect(TutorInterestStatus.fromString('submitted'), TutorInterestStatus.submitted);
      expect(TutorInterestStatus.fromString('withdrawn'), TutorInterestStatus.withdrawn);
    });
  });

  group('Shared UI Widget Tests', () {
    testWidgets('AppButton renders text and triggers onPressed', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit Request',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Request'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(pressed, isTrue);
    });

    testWidgets('AppButton renders loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit Request',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppTextField renders label and hint', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Full Name',
              hint: 'Enter your name',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('AppDropdown renders label and options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDropdown(
              label: 'Grade',
              value: 'Grade 10',
              items: const ['Grade 9', 'Grade 10', 'Grade 11'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Grade'), findsOneWidget);
      expect(find.text('Grade 10'), findsOneWidget);
    });
  });
}
