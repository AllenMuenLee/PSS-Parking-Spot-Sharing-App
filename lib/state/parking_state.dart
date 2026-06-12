import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  ParkingState({
    required this.status,
    this.latitude,
    this.longitude,
    this.parkedAt,
    this.streetName,
  });

  ParkingState copyWith({
    ParkingStatus? status,
    double? latitude,
    double? longitude,
    DateTime? parkedAt,
    String? streetName,
  }) {
    return ParkingState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parkedAt: parkedAt ?? this.parkedAt,
      streetName: streetName ?? this.streetName,
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

  void reset() {
    state = ParkingState(status: ParkingStatus.idle);
  }
}

final parkingStateProvider = StateNotifierProvider<ParkingStateNotifier, ParkingState>((ref) {
  return ParkingStateNotifier();
});
