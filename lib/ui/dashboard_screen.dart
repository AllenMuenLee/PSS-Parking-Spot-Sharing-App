import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/parking_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parkingState = ref.watch(parkingStateProvider);
    final notifier = ref.read(parkingStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Street Parking'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dynamic Status Icon
              Icon(
                _getStatusIcon(parkingState.status),
                size: 120,
                color: _getStatusColor(parkingState.status),
              ),
              const SizedBox(height: 32),
              
              // Status Text
              Text(
                'Current Status:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusText(parkingState.status),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(parkingState.status),
                ),
              ),
              const SizedBox(height: 48),

              // Mock Manual Overrides for Testing
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Manual Testing Overrides',
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
                    child: const Text('Simulate Driving'),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.updateStatus(ParkingStatus.verifying),
                    child: const Text('Simulate Stop'),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.setParked(25.0330, 121.5654, 'Xinyi Road'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Confirm Parked', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.updateStatus(ParkingStatus.leaving),
                    child: const Text('Simulate Departure'),
                  ),
                ],
              ),
              if (parkingState.status == ParkingStatus.parked) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('Parked at: ${parkingState.streetName}'),
                      Text('Time: ${parkingState.parkedAt?.toLocal().toString().split('.')[0]}'),
                    ],
                  ),
                )
              ]
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

  String _getStatusText(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.idle: return 'Idle';
      case ParkingStatus.driving: return 'Driving';
      case ParkingStatus.verifying: return 'Verifying Location...';
      case ParkingStatus.parked: return 'Parked';
      case ParkingStatus.leaving: return 'Leaving Spot';
    }
  }
}
