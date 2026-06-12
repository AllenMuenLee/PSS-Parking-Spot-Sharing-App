# Required Technical Skills & Domains

## 1. Mobile Sensor & Activity Recognition
*   **Android:** `Activity Recognition Transition API` via Google Play Services.

## 2. Geolocation & Mapping
*   **Background Location:** OS-level background location handling (`CLLocationManager` on iOS, `FusedLocationProviderClient` on Android).
*   **Google Maps Roads API:** Using the `snapToRoads` endpoint to verify if a raw GPS coordinate aligns with a street.
*   **Reverse Geocoding:** Converting lat/lng into human-readable street names to display in push notifications.

## 3. Push Notifications & OS Interactions
*   **Interactive Notifications:** Implementing local notifications with actionable buttons (e.g., "Yes" / "No") that can trigger background code execution without requiring the user to open the app.
*   **FCM (Firebase Cloud Messaging):** For broadcasting departure events to other nearby users.

## 4. Backend & Database (Spatio-Temporal)
*   **NoSQL Design:** Structuring Firestore documents to handle geo-queries efficiently (e.g., using `GeoHash`).
*   **State Machine Logic:** Managing transitions between `driving_status`, `parking_verification_pending`, `parked`, and `departing`.