import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_parking_app/state/parking_state.dart';

void main() {
  group('ParkingStateNotifier', () {
    late ParkingStateNotifier notifier;

    setUp(() {
      notifier = ParkingStateNotifier();
    });

    test('initial state is idle', () {
      expect(notifier.debugState.status, ParkingStatus.idle);
      expect(notifier.debugState.isSearchModeEnabled, false);
    });

    test('toggleSearchMode changes isSearchModeEnabled', () async {
      SharedPreferences.setMockInitialValues({});
      notifier.toggleSearchMode(true);
      // Let the future complete
      await Future.delayed(Duration.zero);
      expect(notifier.debugState.isSearchModeEnabled, true);
    });

    test('updateStatus changes status', () {
      notifier.updateStatus(ParkingStatus.driving);
      expect(notifier.debugState.status, ParkingStatus.driving);
    });

    test('setParked updates status and location', () {
      notifier.setParked(25.0, 121.0, 'Main St');
      expect(notifier.debugState.status, ParkingStatus.parked);
      expect(notifier.debugState.latitude, 25.0);
      expect(notifier.debugState.longitude, 121.0);
      expect(notifier.debugState.streetName, 'Main St');
      expect(notifier.debugState.parkedAt, isNotNull);
    });

    test('reset clears the state', () {
      notifier.setParked(25.0, 121.0, 'Main St');
      notifier.reset();
      expect(notifier.debugState.status, ParkingStatus.idle);
      expect(notifier.debugState.latitude, isNull);
      expect(notifier.debugState.streetName, isNull);
    });
  });
}
