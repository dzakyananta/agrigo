import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocalWeatherService {
  // Menggunakan layanan cuaca gratis tanpa API key
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Get current location
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Get location name from coordinates
  static Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return 'Unknown Location';
  }

  // Get weather by coordinates using Open-Meteo (free, no API key needed)
  static Future<Map<String, dynamic>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,pressure_msl&timezone=Asia%2FJakarta',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data, lat, lon);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather by city name (using geocoding first)
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      // Get coordinates from city name
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return await getWeatherByCoordinates(
          location.latitude,
          location.longitude,
        );
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      throw Exception('Error fetching weather for city: $e');
    }
  }

  // Get weather forecast using Open-Meteo
  static Future<List<Map<String, dynamic>>> getWeatherForecast(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&hourly=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=Asia%2FJakarta&forecast_days=2',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecastData(data);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Parse current weather data from Open-Meteo
  static Map<String, dynamic> _parseWeatherData(
    Map<String, dynamic> data,
    double lat,
    double lon,
  ) {
    final current = data['current'];

    return {
      'temperature': current['temperature_2m'].toDouble(),
      'feelsLike': current['temperature_2m'].toDouble() + 2, // Estimasi
      'humidity': current['relative_humidity_2m'],
      'pressure': current['pressure_msl'],
      'description': _getWeatherDescription(current['weather_code']),
      'main': _getWeatherMain(current['weather_code']),
      'icon': _getWeatherIcon(current['weather_code']),
      'windSpeed': current['wind_speed_10m'].toDouble(),
      'windDegree': 0, // Not available in free API
      'visibility': 10000, // Default value
      'cloudiness': 0, // Not available in free API
      'sunrise': DateTime.now().subtract(Duration(hours: 2)), // Estimasi
      'sunset': DateTime.now().add(Duration(hours: 8)), // Estimasi
      'cityName': 'Current Location',
      'country': 'ID',
      'coordinates': {'lat': lat, 'lon': lon},
    };
  }

  // Parse forecast data from Open-Meteo
  static List<Map<String, dynamic>> _parseForecastData(
    Map<String, dynamic> data,
  ) {
    List<Map<String, dynamic>> forecasts = [];
    final hourly = data['hourly'];
    final times = hourly['time'];
    final temps = hourly['temperature_2m'];
    final humidity = hourly['relative_humidity_2m'];
    final weatherCodes = hourly['weather_code'];
    final windSpeeds = hourly['wind_speed_10m'];

    for (int i = 0; i < times.length && i < 48; i++) {
      forecasts.add({
        'datetime': DateTime.parse(times[i]),
        'temperature': temps[i].toDouble(),
        'feelsLike': temps[i].toDouble() + 2,
        'tempMin': temps[i].toDouble() - 1,
        'tempMax': temps[i].toDouble() + 3,
        'humidity': humidity[i],
        'description': _getWeatherDescription(weatherCodes[i]),
        'main': _getWeatherMain(weatherCodes[i]),
        'icon': _getWeatherIcon(weatherCodes[i]),
        'windSpeed': windSpeeds[i].toDouble(),
        'cloudiness': 0,
      });
    }

    return forecasts;
  }

  // Convert WMO weather codes to descriptions (Indonesian)
  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'cerah';
      case 1:
      case 2:
      case 3:
        return 'cerah berawan';
      case 45:
      case 48:
        return 'berkabut';
      case 51:
      case 53:
      case 55:
        return 'gerimis';
      case 61:
      case 63:
      case 65:
        return 'hujan';
      case 71:
      case 73:
      case 75:
        return 'bersalju';
      case 95:
      case 96:
      case 99:
        return 'badai petir';
      default:
        return 'tidak diketahui';
    }
  }

  // Convert WMO weather codes to main categories
  static String _getWeatherMain(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Clouds';
    if (code >= 45 && code <= 48) return 'Mist';
    if (code >= 51 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 75) return 'Snow';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  // Convert WMO weather codes to icon codes
  static String _getWeatherIcon(int code) {
    if (code == 0) return '01d';
    if (code >= 1 && code <= 3) return '02d';
    if (code >= 45 && code <= 48) return '50d';
    if (code >= 51 && code <= 65) return '10d';
    if (code >= 71 && code <= 75) return '13d';
    if (code >= 95 && code <= 99) return '11d';
    return '01d';
  }

  // Get farming advice based on weather
  static String getFarmingAdvice(Map<String, dynamic> weather) {
    double temp = weather['temperature'];
    int humidity = weather['humidity'];
    double windSpeed = weather['windSpeed'];
    String main = weather['main'].toLowerCase();

    List<String> advice = [];

    if (temp < 15) {
      advice.add('Suhu dingin, lindungi tanaman sensitif');
    } else if (temp > 35) {
      advice.add('Suhu panas, pastikan irigasi cukup');
    }

    if (humidity > 80) {
      advice.add('Kelembaban tinggi, waspada penyakit jamur');
    } else if (humidity < 30) {
      advice.add('Kelembaban rendah, tingkatkan penyiraman');
    }

    if (windSpeed > 10) {
      advice.add('Angin kencang, periksa struktur penyangga tanaman');
    }

    switch (main) {
      case 'rain':
        advice.add('Hujan - baik untuk tanaman, tunda penyemprotan pestisida');
        break;
      case 'clear':
        advice.add('Cuaca cerah - waktu baik untuk aktivitas lapangan');
        break;
      case 'clouds':
        advice.add('Berawan - kondisi baik untuk penanaman');
        break;
      case 'thunderstorm':
        advice.add('Badai petir - hindari aktivitas di lapangan terbuka');
        break;
    }

    return advice.isEmpty
        ? 'Kondisi cuaca normal untuk pertanian'
        : advice.join('. ');
  }
}
