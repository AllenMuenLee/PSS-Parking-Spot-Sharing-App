import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'maps_service.dart';
import 'firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background notification actions (Yes/No)
  print('Notification action tapped: ${notificationResponse.actionId}');
  final firebaseService = FirebaseService();
  
  if (notificationResponse.actionId == 'confirm_park') {
    // Ideally we pass location in payload
    // For demo purposes, we fetch again or parse from payload
    // Here we'll just parse the payload assuming "lat,lng,street"
    final payload = notificationResponse.payload;
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length == 3) {
        final lat = double.tryParse(parts[0]) ?? 0;
        final lng = double.tryParse(parts[1]) ?? 0;
        final street = parts[2];
        firebaseService.saveParkingEvent(
          latitude: lat,
          longitude: lng,
          streetName: street,
        );
      }
    }
  }
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'parking_app_service', // id
    'Parking Detection Service', // title
    description: 'This channel is used for parking detection.', // description
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize notifications to handle actions
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
    ),
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'parking_app_service',
      initialNotificationTitle: 'Parking Service Active',
      initialNotificationContent: 'Monitoring for parking events',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final firebaseService = FirebaseService();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  ActivityType currentActivity = ActivityType.UNKNOWN;

  // Listen to Activity Recognition
  ActivityRecognition.activityStream().listen((ActivityEvent event) async {
    final prevActivity = currentActivity;
    currentActivity = event.type;

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Parking Detection",
          content: "Status: ${currentActivity.name} at ${DateTime.now().hour}:${DateTime.now().minute}",
        );
      }
    }

    // Detect Stop: IN_VEHICLE -> ON_FOOT / STILL
    if (prevActivity == ActivityType.IN_VEHICLE && 
       (currentActivity == ActivityType.ON_FOOT || currentActivity == ActivityType.STILL)) {
      
      // Get Location
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print('Location error: $e');
        return;
      }

      // Geo-Verify
      final streetName = await MapsService.verifyStreetParking(position.latitude, position.longitude);
      
      if (streetName != null) {
        // Show confirmation notification
        await flutterLocalNotificationsPlugin.show(
          1,
          'Parking Detected',
          'Did you just park on $streetName?',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'parking_app_alerts',
              'Parking Alerts',
              importance: Importance.max,
              priority: Priority.high,
              actions: [
                const AndroidNotificationAction(
                  'confirm_park',
                  'Parked',
                  showsUserInterface: true,
                ),
                const AndroidNotificationAction(
                  'cancel_park',
                  'Not Parked',
                ),
              ],
            ),
          ),
          payload: '${position.latitude}|${position.longitude}|$streetName',
        );
      }
    }

    // Detect Departure: ON_FOOT -> IN_VEHICLE
    if ((prevActivity == ActivityType.ON_FOOT || prevActivity == ActivityType.STILL) && 
        currentActivity == ActivityType.IN_VEHICLE) {
      
      // Try to get current location to free the spot
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await firebaseService.markSpotAsAvailable(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      } catch (e) {
         print('Location error freeing spot: $e');
      }
    }
  });

  // Listen to new available spots for Search Parking Mode
  FirebaseFirestore.instance
      .collection('available_spots')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .listen((snapshot) async {
    if (snapshot.docChanges.isNotEmpty) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final prefs = await SharedPreferences.getInstance();
          final isSearchModeEnabled = prefs.getBool('isSearchModeEnabled') ?? false;
          if (isSearchModeEnabled) {
            final data = change.doc.data() as Map<String, dynamic>;
            final lat = data['latitude'];
            final lng = data['longitude'];

            // Optional: check if nearby, but for demo we just show it
            await flutterLocalNotificationsPlugin.show(
              2,
              'Parking Available',
              'A parking spot just opened nearby.',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'parking_app_alerts',
                  'Parking Alerts',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
              payload: 'map|$lat|$lng',
            );
          }
        }
      }
    }
  });
}
