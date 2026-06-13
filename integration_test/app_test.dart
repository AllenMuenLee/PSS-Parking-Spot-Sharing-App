import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:street_parking_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End full user journey simulation', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Current Status:'), findsOneWidget);
    expect(find.text('Idle'), findsOneWidget);

    // Simulate Driving
    await tester.tap(find.text('Simulate Driving'));
    await tester.pumpAndSettle();
    expect(find.text('Driving'), findsOneWidget);

    // Simulate Stop (which triggers verifying state)
    await tester.tap(find.text('Simulate Stop'));
    await tester.pumpAndSettle();
    expect(find.text('Verifying Location...'), findsOneWidget);

    // Confirm Parked
    await tester.tap(find.text('Confirm Parked'));
    await tester.pumpAndSettle();
    expect(find.text('Parked'), findsOneWidget);
    expect(find.text('Parked at: Xinyi Road'), findsOneWidget);
    expect(find.textContaining('Time Parked:'), findsOneWidget);

    // Simulate Departure
    await tester.tap(find.text('Simulate Departure'));
    await tester.pumpAndSettle();
    expect(find.text('Leaving Spot'), findsOneWidget);
  });
}
