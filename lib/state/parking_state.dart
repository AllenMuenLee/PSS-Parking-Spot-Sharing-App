import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ParkingStatus {
  idle,       // App started, unknown status
  driving,    // User is IN_VEHICLE
  verifying,  // Transition to ON_FOOT detected, querying GPS/Maps
  parked,     // Confirmed parked on street
  leaving,    // Transition to IN_VEHICLE detected, releasing spot
}

class ParkingState {
  final ParkingStatus status;
  final double? latitude;
  final double? longitude;
  final DateTime? parkedAt;
  final String? streetName;
  final bool isSearchModeEnabled;

  ParkingState({
    required this.status,
    this.latitude,
    this.longitude,
    this.parkedAt,
    this.streetName,
    this.isSearchModeEnabled = false,
  });

  ParkingState copyWith({
    ParkingStatus? status,
    double? latitude,
    double? longitude,
    DateTime? parkedAt,
    String? streetName,
    bool? isSearchModeEnabled,
  }) {
    return ParkingState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parkedAt: parkedAt ?? this.parkedAt,
      streetName: streetName ?? this.streetName,
      isSearchModeEnabled: isSearchModeEnabled ?? this.isSearchModeEnabled,
    );
  }
}

class ParkingStateNotifier extends StateNotifier<ParkingState> {
  ParkingStateNotifier() : super(ParkingState(status: ParkingStatus.idle));

  void updateStatus(ParkingStatus newStatus) {
    state = state.copyWith(status: newStatus);
  }

  void setParked(double lat, double lng, String street) {
    state = state.copyWith(
      status: ParkingStatus.parked,
      latitude: lat,
      longitude: lng,
      streetName: street,
      parkedAt: DateTime.now(),
    );
  }

  void toggleSearchMode(bool enabled) async {
    state = state.copyWith(isSearchModeEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSearchModeEnabled', enabled);
  }

  void reset() {
    state = ParkingState(status: ParkingStatus.idle, isSearchModeEnabled: state.isSearchModeEnabled);
  }
}

final parkingStateProvider = StateNotifierProvider<ParkingStateNotifier, ParkingState>((ref) {
  return ParkingStateNotifier();
});
