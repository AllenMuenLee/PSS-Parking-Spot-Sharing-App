// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Street Parking';

  @override
  String get statusIdle => 'Idle';

  @override
  String get statusDriving => 'Driving';

  @override
  String get statusVerifying => 'Verifying Location...';

  @override
  String get statusParked => 'Parked';

  @override
  String get statusLeaving => 'Leaving Spot';

  @override
  String get currentStatus => 'Current Status:';

  @override
  String get manualTesting => 'Manual Testing Overrides';

  @override
  String get simulateDriving => 'Simulate Driving';

  @override
  String get simulateStop => 'Simulate Stop';

  @override
  String get confirmParked => 'Confirm Parked';

  @override
  String get simulateDeparture => 'Simulate Departure';

  @override
  String parkedAt(String street) {
    return 'Parked at: $street';
  }

  @override
  String time(String time) {
    return 'Time: $time';
  }
}
