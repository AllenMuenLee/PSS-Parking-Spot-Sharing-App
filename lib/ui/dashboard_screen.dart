import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../state/parking_state.dart';
import '../state/locale_state.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _timer;
  String _elapsedTime = '00:00:00';
  final FirebaseService _firebaseService = FirebaseService();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(parkingStateProvider);
      if (state.status == ParkingStatus.parked && state.parkedAt != null) {
        final duration = DateTime.now().difference(state.parkedAt!);
        final hours = duration.inHours.toString().padLeft(2, '0');
        final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        setState(() {
          _elapsedTime = '$hours:$minutes:$seconds';
        });
      } else if (_elapsedTime != '00:00:00') {
        setState(() {
          _elapsedTime = '00:00:00';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final parkingState = ref.watch(parkingStateProvider);
    final notifier = ref.read(parkingStateProvider.notifier);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale = locale.languageCode == 'en' ? const Locale('zh') : const Locale('en');
              ref.read(localeProvider.notifier).setLocale(newLocale);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Mode Toggle
              SwitchListTile(
                title: const Text('Search Parking Mode'),
                value: parkingState.isSearchModeEnabled,
                onChanged: (val) => notifier.toggleSearchMode(val),
              ),
              const SizedBox(height: 16),

              // Embedded Map
              if (parkingState.isSearchModeEnabled)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firebaseService.getAvailableSpots(),
                      builder: (context, snapshot) {
                        Set<Marker> markers = {};
                        if (snapshot.hasData) {
                          for (var spot in snapshot.data!) {
                            final lat = spot['latitude'];
                            final lng = spot['longitude'];
                            if (lat != null && lng != null) {
                              markers.add(Marker(
                                markerId: MarkerId('$lat-$lng'),
                                position: LatLng(lat, lng),
                                infoWindow: const InfoWindow(title: 'Available Spot'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                              ));
                            }
                          }
                        }

                        // Center map on Taipei for demo if no markers
                        LatLng center = markers.isNotEmpty ? markers.first.position : const LatLng(25.0330, 121.5654);

                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: center,
                            zoom: 14,
                          ),
                          markers: markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Dynamic Status Icon
              Icon(
                _getStatusIcon(parkingState.status),
                size: 100,
                color: _getStatusColor(parkingState.status),
              ),
              const SizedBox(height: 16),
              
              // Status Text
              Text(
                l10n.currentStatus,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusText(parkingState.status, l10n),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(parkingState.status),
                ),
              ),
              const SizedBox(height: 24),

              if (parkingState.status == ParkingStatus.parked) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.parkedAt(parkingState.streetName ?? '')),
                      const SizedBox(height: 8),
                      Text(
                        'Time Parked: $_elapsedTime',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                )
              ],

              // Mock Manual Overrides for Testing
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.manualTesting,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => notifier.updateStatus(ParkingStatus.driving),
                    child: Text(l10n.simulateDriving),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.updateStatus(ParkingStatus.verifying),
                    child: Text(l10n.simulateStop),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.setParked(25.0330, 121.5654, 'Xinyi Road'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(l10n.confirmParked, style: const TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.updateStatus(ParkingStatus.leaving),
                    child: Text(l10n.simulateDeparture),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.idle: return Icons.local_parking_outlined;
      case ParkingStatus.driving: return Icons.directions_car;
      case ParkingStatus.verifying: return Icons.location_searching;
      case ParkingStatus.parked: return Icons.local_parking;
      case ParkingStatus.leaving: return Icons.exit_to_app;
    }
  }

  Color _getStatusColor(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.idle: return Colors.grey;
      case ParkingStatus.driving: return Colors.blue;
      case ParkingStatus.verifying: return Colors.orange;
      case ParkingStatus.parked: return Colors.green;
      case ParkingStatus.leaving: return Colors.purple;
    }
  }

  String _getStatusText(ParkingStatus status, AppLocalizations l10n) {
    switch (status) {
      case ParkingStatus.idle: return l10n.statusIdle;
      case ParkingStatus.driving: return l10n.statusDriving;
      case ParkingStatus.verifying: return l10n.statusVerifying;
      case ParkingStatus.parked: return l10n.statusParked;
      case ParkingStatus.leaving: return l10n.statusLeaving;
    }
  }
}
