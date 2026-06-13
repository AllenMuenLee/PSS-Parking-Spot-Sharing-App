import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_parking_app/ui/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard UI renders and buttons update state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
          ],
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state is Idle
    expect(find.text('Idle'), findsOneWidget);

    // Tap Simulate Driving
    await tester.tap(find.text('Simulate Driving'));
    await tester.pump();
    expect(find.text('Driving'), findsOneWidget);

    // Tap Simulate Stop
    await tester.tap(find.text('Simulate Stop'));
    await tester.pump();
    expect(find.text('Verifying Location...'), findsOneWidget);

    // Tap Confirm Parked
    await tester.tap(find.text('Confirm Parked'));
    await tester.pump();
    expect(find.text('Parked'), findsOneWidget);
    expect(find.text('Parked at: Xinyi Road'), findsOneWidget);
    expect(find.textContaining('Time Parked:'), findsOneWidget);

    // Tap Simulate Departure
    await tester.tap(find.text('Simulate Departure'));
    await tester.pump();
    expect(find.text('Leaving Spot'), findsOneWidget);
  });
}
