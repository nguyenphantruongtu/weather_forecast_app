import 'package:geocoding/geocoding.dart';

class GoogleMapsIntegration {
  /// Converts an address string to geographic coordinates (latitude and longitude)
  /// 
  /// This method uses the geocoding package to perform reverse geocoding
  /// and returns the first location result if found.
  /// 
  /// @param address The address string to geocode
  /// @return Location object containing latitude and longitude, or null if not found
  Future<Location?> getLocationFromAddress(String address) async {
    try {
      // Use geocoding to convert address to coordinates
      List<Location> locations = await locationFromAddress(address);
      
      // Return the first location if available
      if (locations.isNotEmpty) {
        return locations.first;
      }
      
      return null;
    } catch (e) {
      // Handle any errors that occur during geocoding
      print('Error geocoding address: $e');
      return null;
    }
  }
}