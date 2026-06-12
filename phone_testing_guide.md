# How to Test the Street Parking App on Your Android Phone

Follow these step-by-step instructions to compile and test the Flutter application on your physical Android device.

## Step 1: Enable Developer Options on Your Phone
1. Open the **Settings** app on your Android phone.
2. Scroll down and tap **About phone** (or **About device**).
3. Find the **Build number** entry (sometimes located under **Software information**).
4. Tap the **Build number** 7 times rapidly.
5. You may be prompted to enter your device PIN or password. Once entered, you will see a message saying "You are now a developer!".

## Step 2: Enable USB Debugging
1. Go back to the main **Settings** menu.
2. Scroll down and tap on **System**, then tap **Developer options** (on some phones, Developer options might be directly in the main Settings menu or under Additional Settings).
3. Scroll down to the **Debugging** section.
4. Toggle on **USB debugging**.
5. Tap **OK** to allow USB debugging if a warning prompt appears.

## Step 3: Connect Your Phone to Your PC
1. Connect your phone to your computer using a USB cable.
2. Unlock your phone.
3. A prompt will appear on your phone asking to **"Allow USB debugging?"** from this computer's RSA key fingerprint.
4. Check the box that says **"Always allow from this computer"** and tap **Allow**.

## Step 4: Verify the Connection
1. Open PowerShell or a terminal on your PC.
2. Navigate to your project directory (if not already there):
   ```bash
   cd C:\Users\limue\Documents\Projects\路邊停車
   ```
3. Run the following command to ensure your PC and Flutter recognize the device:
   ```bash
   flutter devices
   ```
4. You should see your Android phone listed in the output.

## Step 5: Run the Application
1. Make sure your phone is unlocked and the screen is on.
2. In the terminal (inside the `路邊停車` directory), run:
   ```bash
   flutter run
   ```
3. The first time you build the app, it may take a few minutes as it downloads Gradle dependencies and compiles the native Android code.
4. Once completed, the Street Parking app will launch on your phone.

## Step 6: Testing the Background Features
To effectively test the Phase 1 features (GPS, Activity transitions) without actually driving around, you can simulate conditions while the phone is connected via USB.

Open a second terminal window and use the Android Debug Bridge (`adb`) commands:

**Simulate Walking (Triggering the "Did you park?" prompt):**
```bash
adb shell am broadcast -a com.google.android.gms.location.ACTIVITY_TRANSITION --es "activity_type" "ON_FOOT"
```

**Test Background Battery Optimization (Doze Mode):**
To ensure the app continues listening for parking events when your phone is locked and asleep:
```bash
adb shell dumpsys deviceidle force-idle
```
*(To return to normal battery behavior after testing, run `adb shell dumpsys deviceidle unforce`)*
