import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  // OpenWeatherMap API key - Gunakan API key yang valid atau fallback
  static const String _apiKey = '50f4c9c6c5e8ba48a0bce35b4b8c05bd';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

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

  // Get weather by coordinates
  static Future<Map<String, dynamic>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather by city name
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather forecast (5 days)
  static Future<List<Map<String, dynamic>>> getWeatherForecast(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id',
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

  // Parse current weather data
  static Map<String, dynamic> _parseWeatherData(Map<String, dynamic> data) {
    return {
      'temperature': data['main']['temp'].toDouble(),
      'feelsLike': data['main']['feels_like'].toDouble(),
      'humidity': data['main']['humidity'],
      'pressure': data['main']['pressure'],
      'description': data['weather'][0]['description'],
      'main': data['weather'][0]['main'],
      'icon': data['weather'][0]['icon'],
      'windSpeed': data['wind']['speed'].toDouble(),
      'windDegree': data['wind']['deg'],
      'visibility': data['visibility'],
      'cloudiness': data['clouds']['all'],
      'sunrise': DateTime.fromMillisecondsSinceEpoch(
        data['sys']['sunrise'] * 1000,
      ),
      'sunset': DateTime.fromMillisecondsSinceEpoch(
        data['sys']['sunset'] * 1000,
      ),
      'cityName': data['name'],
      'country': data['sys']['country'],
      'coordinates': {'lat': data['coord']['lat'], 'lon': data['coord']['lon']},
    };
  }

  // Parse forecast data
  static List<Map<String, dynamic>> _parseForecastData(
    Map<String, dynamic> data,
  ) {
    List<Map<String, dynamic>> forecasts = [];

    for (var item in data['list']) {
      forecasts.add({
        'datetime': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
        'temperature': item['main']['temp'].toDouble(),
        'feelsLike': item['main']['feels_like'].toDouble(),
        'tempMin': item['main']['temp_min'].toDouble(),
        'tempMax': item['main']['temp_max'].toDouble(),
        'humidity': item['main']['humidity'],
        'description': item['weather'][0]['description'],
        'main': item['weather'][0]['main'],
        'icon': item['weather'][0]['icon'],
        'windSpeed': item['wind']['speed'].toDouble(),
        'cloudiness': item['clouds']['all'],
      });
    }

    return forecasts;
  }

  // Get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Get weather advice for farmers
  static String getFarmingAdvice(Map<String, dynamic> weather) {
    double temp = weather['temperature'];
    int humidity = weather['humidity'];
    double windSpeed = weather['windSpeed'];
    String main = weather['main'].toLowerCase();

    List<String> advice = [];

    // Temperature advice
    if (temp < 15) {
      advice.add('Suhu dingin, lindungi tanaman sensitif');
    } else if (temp > 35) {
      advice.add('Suhu panas, pastikan irigasi cukup');
    }

    // Humidity advice
    if (humidity > 80) {
      advice.add('Kelembaban tinggi, waspada penyakit jamur');
    } else if (humidity < 30) {
      advice.add('Kelembaban rendah, tingkatkan penyiraman');
    }

    // Wind advice
    if (windSpeed > 10) {
      advice.add('Angin kencang, periksa struktur penyangga tanaman');
    }

    // Weather condition advice
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

  // Check if weather is suitable for specific farming activities
  static Map<String, bool> getFarmingActivitySuitability(
    Map<String, dynamic> weather,
  ) {
    double temp = weather['temperature'];
    int humidity = weather['humidity'];
    double windSpeed = weather['windSpeed'];
    String main = weather['main'].toLowerCase();

    return {
      'planting':
          temp >= 15 && temp <= 30 && !['rain', 'thunderstorm'].contains(main),
      'harvesting': !['rain', 'thunderstorm'].contains(main) && windSpeed < 15,
      'spraying':
          windSpeed < 10 &&
          !['rain', 'thunderstorm'].contains(main) &&
          humidity < 80,
      'irrigation': temp > 25 || humidity < 50,
      'fertilizing': !['rain', 'thunderstorm'].contains(main) && windSpeed < 15,
    };
  }
}