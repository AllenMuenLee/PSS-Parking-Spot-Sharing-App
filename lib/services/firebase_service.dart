import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveParkingEvent({
    required double latitude,
    required double longitude,
    required String streetName,
  }) async {
    try {
      await _firestore.collection('parking_events').add({
        'latitude': latitude,
        'longitude': longitude,
        'streetName': streetName,
        'status': 'Parked',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving parking event: $e');
    }
  }

  Future<void> markSpotAsAvailable({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // In a real app, you would query for the specific document ID of the user's current session.
      // For Phase 1, we simulate adding an "Available" event.
      await _firestore.collection('available_spots').add({
        'latitude': latitude,
        'longitude': longitude,
        'status': 'Available',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking spot as available: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAvailableSpots() {
    return _firestore
        .collection('available_spots')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
