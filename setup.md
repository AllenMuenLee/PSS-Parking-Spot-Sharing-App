# Street Parking App - Phase 1 Implementation Guide

The core Flutter structure and business logic for the application has been set up in your project directory. Since the `flutter` CLI is not installed in the environment, the Android-specific boilerplate needs to be generated locally on your machine once Flutter is installed.

## 1. Local Environment Setup

1. **Install Flutter**: Make sure you have the Flutter SDK installed and added to your PATH.
2. **Initialize Project**: Run the following command in the `路邊停車` directory to generate the required Android native boilerplate without overwriting the existing Dart code:
   ```bash
   flutter create --platforms android .
   ```
3. **Fetch Dependencies**: 
   ```bash
   flutter pub get
   ```

## 2. Android Manifest Configuration

You must add the required permissions and service declarations for background execution and activity recognition.

Open `android/app/src/main/AndroidManifest.xml` and add the following inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

Inside the `<application>` tag, ensure your Background Service is registered:

```xml
<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:foregroundServiceType="location" />
```

## 3. MethodChannel for Activity Recognition

If standard packages (`activity_recognition_flutter`) fail under newer Android SDKs (API 30+), you'll need to write native Kotlin code.

In `android/app/src/main/kotlin/com/example/street_parking_app/MainActivity.kt`:

```kotlin
package com.example.street_parking_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.street_parking/activity_recognition"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startActivityRecognition") {
                // TODO: Initialize Android Activity Recognition API
                result.success("Started")
            } else {
                result.notImplemented()
            }
        }
    }
}
```

## 4. Hardware Simulation and Testing via ADB (CRITICAL)

Because testing physical movement is inefficient, use the Android Debug Bridge (`adb`) to mock hardware states on an emulator or plugged-in device.

### A. Simulating Activity Transitions
To fake the shift from `IN_VEHICLE` to `ON_FOOT`, you can broadcast intents:
```bash
# This depends on the specific receiver your Android code sets up to catch Activity Transitions
adb shell am broadcast -a com.google.android.gms.location.ACTIVITY_TRANSITION --es "activity_type" "ON_FOOT"
```

### B. Doze Mode Testing
To ensure your `flutter_background_service` survives battery optimizations (Doze mode):
```bash
# Force device into IDLE mode
adb shell dumpsys deviceidle force-idle

# Check if the device is in IDLE mode
adb shell dumpsys deviceidle

# To exit IDLE mode
adb shell dumpsys deviceidle unforce
```

### C. Mock Location
Use the emulator's extended controls (Three dots `...` on the sidebar -> Location) to replay a GPX/KML route, or use a Fake GPS app. 

* **Test case**: Set route, observe `IN_VEHICLE` state. Stop the route at a point on the map, wait 30 seconds, trigger `ON_FOOT` intent via ADB. Ensure the application successfully hits the `MapsService` geo-verification and prompts the user.
