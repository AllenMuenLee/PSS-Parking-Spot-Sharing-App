import 'dart:convert';
import 'package:http/http.dart' as http;

class MapsService {
  static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Reverse geocodes the coordinates to check if it's a public street
  /// Returns the street name if on a road, null otherwise.
  static Future<String?> verifyStreetParking(double lat, double lng) async {
    // 1. Road Snapping API (Optional: to ensure we are exactly on a road segment)
    // 2. Reverse Geocoding API (To get the street name)
    
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey&result_type=route'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // If we got a route, we are likely on a street
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Error during geo-verification: $e');
    }
    return null;
  }
}
