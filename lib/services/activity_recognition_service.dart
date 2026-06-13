import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'dart:async';

class ActivityRecognitionService {
  late StreamSubscription<ActivityEvent> _subscription;
  final Function(ActivityType) onTransition;
  ActivityType _currentActivity = ActivityType.UNKNOWN;

  ActivityRecognitionService({required this.onTransition});

  void startListening() {
    // Request permission (in a real app, ensure permissions are granted before this)
    // using permission_handler or similar.
    
    _subscription = ActivityRecognition.activityStream().listen((ActivityEvent event) {
      if (event.type != _currentActivity) {
        _currentActivity = event.type;
        onTransition(_currentActivity);
      }
    });
  }

  void stopListening() {
    _subscription.cancel();
  }
}
