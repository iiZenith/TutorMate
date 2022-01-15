import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutormate/shared/widgets/dynamic_location_selector.dart';

void main() {
  group('DynamicLocationSelector tests', () {
    testWidgets('renders LocationSelection correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicLocationSelector(
              value: const LocationSelection(province: 'Bagmati', district: 'Kathmandu', area: 'Baneshwor'),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify widget builds without error
      expect(find.byType(DynamicLocationSelector), findsOneWidget);
    });
  });
}
