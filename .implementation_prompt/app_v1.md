# Project Overview
Build "Phase 1" of a crowd-sourced street parking application. The framework is **Flutter**, and the initial development phase will target **Android ONLY**. The goal is to implement a semi-automatic parking detection system that minimizes battery drain while accurately recording street parking events through Android background services.

# Core User Flow
1. **Detect Stop:** The app detects when the Android user transitions from "IN_VEHICLE" to "ON_FOOT" or "STILL".
2. **Geo-Verification:** The app checks current GPS coordinates against Google Maps API to ensure the user is on a public street/road, not off-street.
3. **Confirmation Prompt:** If on a street, the app sends a local interactive push notification (FCM/Local): "Did you just park on [Street Name]?".
4. **State Update:** If the user taps "Yes", coordinates and timestamp are saved to Firebase Firestore, updating state to "Parked".
5. **Detect Departure:** Wait until user activity transitions back to "IN_VEHICLE" (or connects to car Bluetooth).
6. **Release Notification:** Update Firestore to mark the spot as "Available" and broadcast to nearby users.

# Tech Stack Recommendation
* **Framework:** Flutter (Dart)
* **Language:** Traditional Chinese(Taiwan), English (allow language switch)
* **Target Platform:** Android (API Level 24+)
* **Backend & DB:** Firebase (Firestore, Firebase Cloud Functions)
* **Maps:** Google Maps Roads API & Geocoding API
* **Key Flutter Packages:**
    * `flutter_background_service` or `workmanager` (for background tasks)
    * `geolocator` (for GPS)
    * `activity_recognition_flutter` (or custom MethodChannels to Android's Activity Recognition Transition API)
    * `flutter_local_notifications`

# Implementation Steps
1. **Configure Android Manifest:** Set up necessary permissions (`ACTIVITY_RECOGNITION`, `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`).
2. **Implement Background Service:** Create an Android foreground/background service in Flutter that listens to Activity Recognition updates without being killed by Android's Doze mode.
3. **Geo-Verification Logic:** Write the function to query Google Maps API for road snapping and reverse geocoding.
4. **Local Notifications:** Implement Android interactive notifications with "Yes/No" broadcast receivers that can update Firestore without bringing the app to the foreground.
5. **State Machine:** Implement the (Idle -> Driving -> Verifying -> Parked -> Leaving) logic using a robust state management solution (e.g., Riverpod or Bloc).

---

# Comprehensive Testing Strategy

Please implement tests across the following four layers to ensure reliability, especially for background services:

## 1. Unit Testing (Business Logic & State)
* **Tool:** `flutter_test`, `mockito`
* **Coverage:** Test the Core State Machine transitions.
* **Mocks:** Mock the API responses from Google Maps (Roads & Geocoding) and Firebase to test logic without network latency or cost. Test the debounce logic (e.g., ignoring a 30-second stop at a traffic light).

## 2. Widget Testing (UI Components)
* **Tool:** `flutter_test`
* **Coverage:** Ensure the main dashboard correctly reflects the current status (Driving, Parked, Searching). Verify that manual override buttons trigger the correct state changes.

## 3. Integration Testing (End-to-End User Flow)
* **Tool:** `integration_test` package
* **Coverage:** Run tests on an Android emulator/real device. Simulate a full user journey: Open App -> Start Driving -> Stop -> Receive Notification -> Click Yes -> Verify Firestore update -> Start Driving -> Verify Release.

## 4. Android Background & Sensor Simulation Testing (CRITICAL)
Since manual testing of driving/walking is inefficient, provide scripts or instructions to test hardware events via ADB (Android Debug Bridge):
* **Mock Location:** Instructions on using emulator controls or Fake GPS apps to simulate route movement and parking.
* **Simulate Activity Transitions:** Use ADB commands to broadcast fake activity intents to the app (e.g., simulating the shift from `IN_VEHICLE` to `ON_FOOT`).
* **Doze Mode Testing:** Provide ADB commands to force the Android device into `IDLE` (Doze) mode to ensure the background service (`flutter_background_service`) survives and wakes up correctly when the user starts walking.
    * *Example ADB command to include in docs:* `adb shell dumpsys deviceidle force-idle`

# Key Constraints
* **Android Battery Optimization:** Strict adherence to Android background location limits. Do not poll GPS continuously. The GPS should only be triggered by an Activity Recognition transition event.
* **Platform Channels:** If existing Flutter packages for Activity Recognition are outdated or unreliable for the latest Android SDKs, write native Kotlin code and communicate via `MethodChannel` and `EventChannel`.