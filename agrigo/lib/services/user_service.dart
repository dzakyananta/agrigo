import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'local_weather_service.dart';

class UserService {
  static const String _userLocationKey = 'user_location';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';

  // Save user location
  static Future<void> saveUserLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLocationKey, location);
  }

  // Get user location
  static Future<String?> getUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLocationKey);
  }

  // Save user profile data
  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userLocationKey, location);
  }

  // Get user profile data
  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
      'location': prefs.getString(_userLocationKey),
    };
  }

  // Get current GPS location and save it
  static Future<String> getCurrentLocationAndSave() async {
    try {
      Position position = await LocalWeatherService.getCurrentLocation();
      String locationName = await LocalWeatherService.getLocationName(
        position.latitude,
        position.longitude,
      );

      // Save the location
      await saveUserLocation(locationName);
      return locationName;
    } catch (e) {
      print('Error getting current location: $e');
      // Return default location if GPS fails
      return 'Jakarta';
    }
  }

  // Clear user data (for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userLocationKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
  }
}
