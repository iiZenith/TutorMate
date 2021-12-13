import 'package:flutter_test/flutter_test.dart';
import 'package:tutormate/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TutorMateApp());
    
    // We should see splash screen first or at least no crash.
    expect(find.byType(TutorMateApp), findsOneWidget);
  });
}
