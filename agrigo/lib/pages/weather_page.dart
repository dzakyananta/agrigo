import 'package:flutter/material.dart';
import '../services/local_weather_service.dart';
import '../services/user_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String selectedLocation = 'Jakarta';
  bool isLoading = true;
  Map<String, dynamic>? currentWeather;
  List<Map<String, dynamic>> hourlyForecast = [];
  List<Map<String, dynamic>> weeklyForecast = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Delay untuk memastikan widget sudah mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermissionAndLoad();
    });
  }

  Future<void> _checkLocationPermissionAndLoad() async {
    if (!mounted) return;

    try {
      // Check location permission terlebih dahulu
      LocationPermission permission = await Geolocator.checkPermission();

      // Jika permission belum pernah diminta atau ditolak, tampilkan popup custom
      if (permission == LocationPermission.denied) {
        // Tampilkan popup custom untuk meminta permission
        bool shouldRequestPermission = await _showPermissionRequestDialog();

        if (shouldRequestPermission) {
          // Request permission dari sistem
          permission = await Geolocator.requestPermission();

          if (permission == LocationPermission.denied) {
            // Permission ditolak, load default Jakarta
            _loadInitialWeatherData();
            return;
          }
        } else {
          // User memilih skip, load default Jakarta
          _loadInitialWeatherData();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission ditolak permanen, tampilkan dialog
        _showPermissionDeniedForeverDialog();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Layanan lokasi tidak aktif
        _showLocationServiceDialog();
        return;
      }

      // Permission granted dan service enabled, ambil lokasi GPS aktual
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print('Permission granted, getting current location...');
        await _getCurrentLocationWeather();
      } else {
        // Fallback jika permission status lain
        _loadInitialWeatherData();
      }
    } catch (e) {
      print('Error checking location permission: $e');
      _loadInitialWeatherData();
    }
  }

  Future<bool> _showPermissionRequestDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Izinkan Akses Lokasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Untuk memberikan informasi cuaca yang akurat sesuai lokasi Anda saat ini, aplikasi memerlukan izin akses lokasi.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Lokasi hanya digunakan untuk menampilkan cuaca',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Nanti Saja',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Izinkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            );
          },
        ) ??
        false;
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 10),
              Text('Layanan Lokasi Tidak Aktif'),
            ],
          ),
          content: Text(
            'Aplikasi memerlukan akses lokasi untuk menampilkan cuaca di sekitar Anda. Silakan aktifkan layanan lokasi di pengaturan perangkat Anda.\n\nAnda akan melihat cuaca Jakarta sebagai default.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Load with default location (Jakarta)
                _loadInitialWeatherData();
              },
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.red),
              SizedBox(width: 10),
              Text('Izin Lokasi Diperlukan'),
            ],
          ),
          content: Text(
            'Izin akses lokasi telah ditolak secara permanen.\n\nUntuk menggunakan lokasi saat ini, silakan:\n1. Buka Pengaturan aplikasi\n2. Aktifkan izin Lokasi\n\nUntuk saat ini, Anda akan melihat cuaca Jakarta.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Try to open app settings
                await Geolocator.openAppSettings();
                // Load with default location
                _loadInitialWeatherData();
              },
              child: Text(
                'Buka Pengaturan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Load with default location
                _loadInitialWeatherData();
              },
              child: Text('Nanti Saja'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadInitialWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('WeatherPage: Starting initial load...');

      // Coba ambil lokasi dari user terlebih dahulu
      String? userLocation = await UserService.getUserLocation();
      if (userLocation != null && userLocation.isNotEmpty) {
        selectedLocation = userLocation;
        print('WeatherPage: Using saved location: $userLocation');
      } else {
        print('WeatherPage: No saved location, using Jakarta');
      }

      // Coba gunakan API terlebih dahulu
      print('WeatherPage: Fetching weather for $selectedLocation...');
      await _getWeatherByCity(selectedLocation);
      print('WeatherPage: Weather loaded successfully');
    } catch (e) {
      print('WeatherPage: Initial load failed - $e');
      print('WeatherPage: Using fallback data...');
      // Jika gagal, gunakan fallback data
      _loadFallbackWeatherData(selectedLocation);
    }
  }

  Future<void> _refreshWeatherDataAsync() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try to get real weather data first
      await _getWeatherByCity(selectedLocation);
    } catch (e) {
      print('Refresh failed, using fallback data: $e');
      // If API fails, use fallback
      await Future.delayed(Duration(milliseconds: 300));
      _loadFallbackWeatherData(selectedLocation);
    }
  }

  Future<void> _loadUserLocationAndWeather() async {
    // Get saved user location
    String? userLocation = await UserService.getUserLocation();
    if (userLocation != null && userLocation.isNotEmpty) {
      selectedLocation = userLocation;
      _loadFallbackWeatherData(userLocation);
    } else {
      // Fallback to Jakarta if no saved location
      _loadFallbackWeatherData('Jakarta');
    }
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Getting current location...');
      // Coba ambil lokasi saat ini dengan timeout
      Position position =
          await LocalWeatherService.getCurrentLocation().timeout(
        Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Location timeout');
        },
      );
      print('Got position: ${position.latitude}, ${position.longitude}');

      // Get location name
      String locationName = await LocalWeatherService.getLocationName(
        position.latitude,
        position.longitude,
      );
      print('Got location name: $locationName');

      // Get weather forecast
      List<Map<String, dynamic>> forecast =
          await LocalWeatherService.getWeatherForecast(
        position.latitude,
        position.longitude,
      );
      print('Got forecast: ${forecast.length} items');

      // SINKRONISASI: Gunakan forecast[0] untuk currentWeather
      Map<String, dynamic> weather;
      if (forecast.isNotEmpty) {
        weather = {
          'temperature': forecast[0]['temperature'],
          'feelsLike': forecast[0]['feelsLike'],
          'humidity': forecast[0]['humidity'],
          'pressure': forecast[0]['pressure'],
          'description': forecast[0]['description'],
          'main': forecast[0]['main'],
          'icon': forecast[0]['icon'],
          'windSpeed': forecast[0]['windSpeed'],
          'visibility': forecast[0]['visibility'],
          'cityName': locationName,
          'coordinates': {'lat': position.latitude, 'lon': position.longitude},
        };
      } else {
        throw Exception('No forecast data available');
      }

      if (mounted) {
        setState(() {
          selectedLocation = locationName;
          currentWeather = weather;
          hourlyForecast = forecast.take(24).toList(); // 24 jam ke depan
          weeklyForecast = _generateWeeklyForecastFromAPI(forecast);
          isLoading = false;
          errorMessage = null;
        });
        print('Weather data loaded successfully');
      }
    } catch (e) {
      // Fallback ke data cuaca lokal jika semua gagal
      print('Error getting location and weather: $e');
      if (mounted) {
        setState(() {
          errorMessage =
              'Tidak dapat mengakses lokasi. Menggunakan data Jakarta.';
        });
        await Future.delayed(Duration(milliseconds: 300));
        _loadFallbackWeatherData('Jakarta');
      }
    }
  }

  Future<void> _getWeatherByCity(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('_getWeatherByCity: Getting weather for $city');

      // Dapatkan koordinat kota terlebih dahulu
      Map<String, dynamic> tempWeather =
          await LocalWeatherService.getWeatherByCity(city);
      print('_getWeatherByCity: Got weather data');

      // Ambil koordinat dari hasil cuaca untuk forecast
      double lat = tempWeather['coordinates']['lat'];
      double lon = tempWeather['coordinates']['lon'];
      print('_getWeatherByCity: Got coordinates - lat: $lat, lon: $lon');

      List<Map<String, dynamic>> forecast =
          await LocalWeatherService.getWeatherForecast(lat, lon);
      print('_getWeatherByCity: Got forecast data, ${forecast.length} items');

      // SINKRONISASI: Gunakan forecast[0] untuk currentWeather
      Map<String, dynamic> weather;
      if (forecast.isNotEmpty) {
        weather = {
          'temperature': forecast[0]['temperature'],
          'feelsLike': forecast[0]['feelsLike'],
          'humidity': forecast[0]['humidity'],
          'pressure': forecast[0]['pressure'],
          'description': forecast[0]['description'],
          'main': forecast[0]['main'],
          'icon': forecast[0]['icon'],
          'windSpeed': forecast[0]['windSpeed'],
          'visibility': forecast[0]['visibility'],
          'cityName': city,
          'coordinates': {'lat': lat, 'lon': lon},
        };
      } else {
        throw Exception('No forecast data available');
      }

      setState(() {
        selectedLocation = city;
        currentWeather = weather;
        hourlyForecast = forecast.take(24).toList();
        weeklyForecast = _generateWeeklyForecastFromAPI(forecast);
        isLoading = false;
        errorMessage = null;
      });
      print('_getWeatherByCity: State updated successfully');
    } catch (e) {
      print('_getWeatherByCity: Error - $e');
      setState(() {
        errorMessage = 'Gagal memuat data cuaca. Menggunakan data lokal.';
      });
      // Fallback ke data cuaca lokal jika API gagal
      await Future.delayed(Duration(milliseconds: 300));
      _loadFallbackWeatherData(city);
    }
  }

  void _loadFallbackWeatherData(String city) {
    print('_loadFallbackWeatherData: Loading fallback data for $city');

    // Data cuaca realistis berdasarkan waktu dan kota
    DateTime now = DateTime.now();
    int currentDay = now.day;

    // Variasi suhu berdasarkan waktu
    double baseTemp = _getCityBaseTemp(city);
    double dailyVariation = (currentDay % 5) - 2; // Variasi harian

    // Generate forecast data yang lebih realistis
    List<Map<String, dynamic>> fallbackForecast = [];
    for (int i = 0; i < 24; i++) {
      DateTime futureTime = now.add(Duration(hours: i));
      int futureHour = futureTime.hour;
      double tempVariation = _getHourlyTempVariation(futureHour);
      double temp = baseTemp + tempVariation + dailyVariation + (i % 3) - 1;

      fallbackForecast.add({
        'datetime': futureTime,
        'temperature': temp,
        'feelsLike': temp + 2 + (futureHour % 3),
        'humidity': _getRealisticHumidity(futureHour),
        'windSpeed': _getRealisticWindSpeed(futureHour, city),
        'visibility': _getRealisticVisibility(futureHour, city),
        'pressure': _getRealisticPressure(futureHour, currentDay),
        'description': _getRealisticWeatherDescription(futureHour),
        'main': _getRealisticWeatherMain(futureHour),
        'icon': _getTimeBasedIcon(futureTime),
      });
    }

    // Ambil data cuaca saat ini dari forecast jam pertama (index 0)
    // SINKRONISASI: currentWeather menggunakan data yang SAMA dengan hourlyForecast[0]
    Map<String, dynamic> currentForecast = fallbackForecast[0];

    Map<String, dynamic> fallbackWeather = {
      'temperature': currentForecast['temperature'],
      'feelsLike': currentForecast['feelsLike'],
      'humidity': currentForecast['humidity'],
      'pressure': currentForecast['pressure'],
      'description': currentForecast['description'],
      'main': currentForecast['main'],
      'icon': currentForecast['icon'],
      'windSpeed': currentForecast['windSpeed'],
      'visibility': currentForecast['visibility'],
      'cityName': city,
      'coordinates': _getCityCoordinates(city),
    };

    setState(() {
      selectedLocation = city;
      currentWeather = fallbackWeather;
      hourlyForecast = fallbackForecast;
      weeklyForecast = _generateWeeklyForecastFromAPI(fallbackForecast);
      isLoading = false;
      errorMessage = null;
    });

    print('_loadFallbackWeatherData: Fallback data loaded successfully');
  }

  double _getCityBaseTemp(String city) {
    switch (city.toLowerCase()) {
      case 'jakarta':
        return 29.0;
      case 'bandung':
        return 25.0;
      case 'surabaya':
        return 31.0;
      case 'medan':
        return 28.0;
      case 'makassar':
        return 30.0;
      case 'palembang':
        return 29.5;
      case 'semarang':
        return 28.5;
      case 'yogyakarta':
        return 27.0;
      default:
        return 28.0;
    }
  }

  double _getHourlyTempVariation(int hour) {
    // Simulasi perubahan suhu sepanjang hari
    if (hour >= 6 && hour <= 12) return (hour - 6) * 1.5; // Naik pagi ke siang
    if (hour >= 13 && hour <= 15) return 9.0; // Puncak siang
    if (hour >= 16 && hour <= 18) return 9.0 - (hour - 15) * 1.0; // Turun sore
    if (hour >= 19 && hour <= 23) return 6.0 - (hour - 18) * 0.8; // Turun malam
    return 2.0 - hour * 0.3; // Dini hari
  }

  int _getRealisticHumidity(int hour) {
    // Kelembaban tinggi pagi/malam, rendah siang
    if (hour >= 6 && hour <= 10) return 65 + (hour % 3) * 3; // Pagi: 65-71%
    if (hour >= 11 && hour <= 15) return 45 + (hour % 4) * 4; // Siang: 45-57%
    if (hour >= 16 && hour <= 19) return 55 + (hour % 3) * 5; // Sore: 55-65%
    return 70 + (hour % 2) * 5; // Malam: 70-75%
  }

  double _getRealisticWindSpeed(int hour, String city) {
    // Kecepatan angin bervariasi berdasarkan waktu dan lokasi
    double baseWind = 2.0;
    if (city.toLowerCase() == 'jakarta') baseWind = 1.5; // Jakarta lebih tenang
    if (city.toLowerCase() == 'surabaya')
      baseWind = 3.0; // Surabaya lebih berangin
    if (city.toLowerCase() == 'makassar') baseWind = 2.5; // Makassar dekat laut

    // Angin lebih kencang siang hari
    if (hour >= 11 && hour <= 16) return baseWind + 1.5 + (hour % 3) * 0.5;
    if (hour >= 6 && hour <= 10) return baseWind + 0.5 + (hour % 2) * 0.3;
    return baseWind + (hour % 2) * 0.2;
  }

  int _getRealisticVisibility(int hour, String city) {
    // Jarak pandang dalam meter
    int baseVisibility = 8000;
    if (city.toLowerCase() == 'jakarta')
      baseVisibility = 6000; // Jakarta lebih berpolusi
    if (city.toLowerCase() == 'bandung')
      baseVisibility = 9000; // Bandung lebih bersih

    // Jarak pandang lebih baik siang hari
    if (hour >= 10 && hour <= 16) return baseVisibility + 2000;
    if (hour >= 6 && hour <= 9 || hour >= 17 && hour <= 19)
      return baseVisibility + 1000;
    return baseVisibility; // Malam dan dini hari
  }

  double _getRealisticPressure(int hour, int day) {
    // Tekanan udara dalam hPa (1013.25 hPa = standar)
    double basePressure = 1013.0;

    // Variasi harian
    double dailyVariation = (day % 7) - 3; // -3 to +3 hPa

    // Tekanan biasanya lebih tinggi pagi hari
    if (hour >= 6 && hour <= 10) return basePressure + 2 + dailyVariation;
    if (hour >= 11 && hour <= 15) return basePressure - 1 + dailyVariation;
    if (hour >= 16 && hour <= 20) return basePressure + 1 + dailyVariation;
    return basePressure + dailyVariation;
  }

  String _getRealisticWeatherDescription(int hour) {
    if (hour >= 6 && hour <= 10) return 'cerah berawan';
    if (hour >= 11 && hour <= 15) return 'cerah';
    if (hour >= 16 && hour <= 18) return 'berawan sebagian';
    return 'cerah berawan';
  }

  String _getRealisticWeatherMain(int hour) {
    if (hour >= 11 && hour <= 15) return 'Clear';
    return 'Clouds';
  }

  Map<String, double> _getCityCoordinates(String city) {
    switch (city.toLowerCase()) {
      case 'jakarta':
        return {'lat': -6.2088, 'lon': 106.8456};
      case 'bandung':
        return {'lat': -6.9175, 'lon': 107.6191};
      case 'surabaya':
        return {'lat': -7.2575, 'lon': 112.7521};
      case 'medan':
        return {'lat': 3.5952, 'lon': 98.6722};
      case 'makassar':
        return {'lat': -5.1477, 'lon': 119.4327};
      case 'palembang':
        return {'lat': -2.9761, 'lon': 104.7754};
      case 'semarang':
        return {'lat': -6.9667, 'lon': 110.4167};
      case 'yogyakarta':
        return {'lat': -7.7956, 'lon': 110.3695};
      default:
        return {'lat': -6.2088, 'lon': 106.8456};
    }
  }

  String _getTimeBasedIcon(DateTime time) {
    int hour = time.hour;
    if (hour >= 6 && hour <= 18) {
      return '01d'; // Siang
    } else {
      return '01n'; // Malam
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'drizzle':
        return Icons.beach_access;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.foggy;
      // Original icon codes for backward compatibility
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.wb_sunny_outlined;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.beach_access;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherIconColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'clouds':
        return Colors.grey;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.purple;
      case 'snow':
        return Colors.lightBlue;
      case 'mist':
      case 'fog':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  List<Map<String, dynamic>> _generateWeeklyForecast() {
    List<Map<String, dynamic>> weeklyData = [];
    DateTime now = DateTime.now();
    double baseTemp = _getCityBaseTemp(selectedLocation);

    // More realistic weather patterns based on season and location
    List<Map<String, dynamic>> weatherPatterns = _getSeasonalWeatherPatterns();

    for (int i = 0; i < 7; i++) {
      DateTime futureDate = now.add(Duration(days: i));

      // Get day name
      String dayName;
      if (i == 0) {
        dayName = 'Hari Ini';
      } else if (i == 1) {
        dayName = 'Besok';
      } else {
        List<String> actualDays = [
          'Minggu',
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
        ];
        dayName = actualDays[futureDate.weekday % 7];
      }

      // Get weather pattern for this day
      var pattern = weatherPatterns[i % weatherPatterns.length];

      // Calculate temperatures with realistic daily variation
      double dailyTempVariation = _getDailyTemperatureVariation(
        i,
        selectedLocation,
      );
      double maxTemp = baseTemp + dailyTempVariation + pattern['tempAdjust'];
      double minTemp = maxTemp - (6 + (i % 2) + pattern['tempRange']);

      // Ensure temperatures are within realistic bounds
      maxTemp = maxTemp.clamp(baseTemp - 8, baseTemp + 12);
      minTemp = minTemp.clamp(maxTemp - 12, maxTemp - 3);

      weeklyData.add({
        'day': dayName,
        'date': futureDate,
        'temp_max': maxTemp.round(),
        'temp_min': minTemp.round(),
        'main': pattern['condition'],
        'description': pattern['description'],
        'humidity': _getRealisticDailyHumidity(i, pattern['condition']),
        'windSpeed': _getRealisticDailyWindSpeed(
          i,
          selectedLocation,
          pattern['condition'],
        ),
      });
    }

    return weeklyData;
  }

  List<Map<String, dynamic>> _getSeasonalWeatherPatterns() {
    DateTime now = DateTime.now();
    int month = now.month;

    // Indonesian seasonal weather patterns
    if (month >= 11 || month <= 3) {
      // Rainy season (November - March)
      return [
        {
          'condition': 'Clouds',
          'description': 'Berawan',
          'tempAdjust': 0.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Rain',
          'description': 'Hujan ringan',
          'tempAdjust': -2.0,
          'tempRange': 1.5,
        },
        {
          'condition': 'Clouds',
          'description': 'Berawan sebagian',
          'tempAdjust': 1.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Rain',
          'description': 'Hujan sedang',
          'tempAdjust': -3.0,
          'tempRange': 2.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah berawan',
          'tempAdjust': 2.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clouds',
          'description': 'Berawan',
          'tempAdjust': -1.0,
          'tempRange': 1.5,
        },
        {
          'condition': 'Rain',
          'description': 'Hujan ringan',
          'tempAdjust': -1.5,
          'tempRange': 1.5,
        },
      ];
    } else if (month >= 4 && month <= 6) {
      // Transition to dry season (April - June)
      return [
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 2.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clouds',
          'description': 'Cerah berawan',
          'tempAdjust': 1.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 3.0,
          'tempRange': 1.5,
        },
        {
          'condition': 'Clouds',
          'description': 'Berawan sebagian',
          'tempAdjust': 0.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 2.5,
          'tempRange': 1.0,
        },
        {
          'condition': 'Rain',
          'description': 'Hujan ringan',
          'tempAdjust': -1.0,
          'tempRange': 2.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah berawan',
          'tempAdjust': 1.5,
          'tempRange': 1.0,
        },
      ];
    } else {
      // Dry season (July - October)
      return [
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 3.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 4.0,
          'tempRange': 1.5,
        },
        {
          'condition': 'Clouds',
          'description': 'Cerah berawan',
          'tempAdjust': 2.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 3.5,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clouds',
          'description': 'Berawan sebagian',
          'tempAdjust': 1.0,
          'tempRange': 1.5,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah',
          'tempAdjust': 3.0,
          'tempRange': 1.0,
        },
        {
          'condition': 'Clear',
          'description': 'Cerah berawan',
          'tempAdjust': 2.5,
          'tempRange': 1.0,
        },
      ];
    }
  }

  double _getDailyTemperatureVariation(int dayIndex, String city) {
    // Temperature tends to gradually change over days
    double baseVariation = (dayIndex * 0.5) - 1.5; // -1.5 to +1.5 over 7 days

    // City-specific adjustments
    if (city.toLowerCase() == 'bandung') {
      baseVariation -= 2.0; // Bandung is cooler
    } else if (city.toLowerCase() == 'surabaya') {
      baseVariation += 1.5; // Surabaya is warmer
    }

    return baseVariation;
  }

  int _getRealisticDailyHumidity(int dayIndex, String condition) {
    int baseHumidity = 65;

    // Weather condition affects humidity
    switch (condition.toLowerCase()) {
      case 'rain':
        baseHumidity = 80 + (dayIndex % 3) * 3;
        break;
      case 'clouds':
        baseHumidity = 70 + (dayIndex % 4) * 2;
        break;
      case 'clear':
        baseHumidity = 55 + (dayIndex % 3) * 4;
        break;
    }

    return baseHumidity.clamp(40, 90);
  }

  double _getRealisticDailyWindSpeed(
    int dayIndex,
    String city,
    String condition,
  ) {
    double baseWind = 2.0;

    // City-specific wind patterns
    if (city.toLowerCase() == 'jakarta') baseWind = 1.8;
    if (city.toLowerCase() == 'surabaya') baseWind = 3.2;
    if (city.toLowerCase() == 'makassar') baseWind = 2.8;

    // Weather condition affects wind speed
    switch (condition.toLowerCase()) {
      case 'rain':
        baseWind += 1.5 + (dayIndex % 2) * 0.8;
        break;
      case 'clouds':
        baseWind += 0.5 + (dayIndex % 3) * 0.4;
        break;
      case 'clear':
        baseWind += (dayIndex % 2) * 0.3;
        break;
    }

    return baseWind.clamp(1.0, 6.0);
  }

  List<Map<String, dynamic>> _generateWeeklyForecastFromAPI(
    List<Map<String, dynamic>> apiData,
  ) {
    List<Map<String, dynamic>> weeklyData = [];

    // Group hourly data by days
    Map<String, List<Map<String, dynamic>>> dailyData = {};

    for (var hourlyData in apiData) {
      String dayKey = DateFormat('yyyy-MM-dd').format(hourlyData['datetime']);
      if (!dailyData.containsKey(dayKey)) {
        dailyData[dayKey] = [];
      }
      dailyData[dayKey]!.add(hourlyData);
    }

    List<String> dayNames = ['Hari Ini', 'Besok'];
    int dayIndex = 0;

    dailyData.forEach((dateKey, hourlyList) {
      if (weeklyData.length >= 7) return;

      DateTime date = DateTime.parse(dateKey);

      // Calculate min/max temperature for the day
      double minTemp = hourlyList
          .map((h) => h['temperature'] as double)
          .reduce((a, b) => a < b ? a : b);
      double maxTemp = hourlyList
          .map((h) => h['temperature'] as double)
          .reduce((a, b) => a > b ? a : b);

      // Get most common weather condition
      Map<String, int> conditionCount = {};
      String mostCommonCondition = 'Clear';
      String description = 'Cerah';

      for (var hour in hourlyList) {
        String condition = hour['main'] ?? 'Clear';
        conditionCount[condition] = (conditionCount[condition] ?? 0) + 1;
        if (conditionCount[condition]! >
            (conditionCount[mostCommonCondition] ?? 0)) {
          mostCommonCondition = condition;
          description = hour['description'] ?? 'Cerah';
        }
      }

      String dayName;
      if (dayIndex < dayNames.length) {
        dayName = dayNames[dayIndex];
      } else {
        List<String> actualDays = [
          'Minggu',
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
        ];
        dayName = actualDays[date.weekday % 7];
      }

      weeklyData.add({
        'day': dayName,
        'date': date,
        'temp_max': maxTemp.round(),
        'temp_min': minTemp.round(),
        'main': mostCommonCondition,
        'description': _capitalizeFirst(description),
        'humidity': hourlyList.isNotEmpty ? hourlyList.first['humidity'] : 65,
        'windSpeed':
            hourlyList.isNotEmpty ? hourlyList.first['windSpeed'] : 2.5,
      });

      dayIndex++;
    });

    // Fill remaining days with fallback data if needed
    while (weeklyData.length < 7) {
      weeklyData.addAll(_generateWeeklyForecast().skip(weeklyData.length));
      break;
    }

    return weeklyData.take(7).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _refreshWeatherDataAsync();
          },
          child: Column(
            children: [
              // App Bar Header
              Container(
                padding: EdgeInsets.all(32),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Prakiraan Cuaca',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24), // Balance the back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      // Location display only
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black87,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  selectedLocation,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Main Weather Card - Sesuai gambar dengan lebar maksimal
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 6,
                        ), // Margin minimal untuk card sangat lebar
                        padding: EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.25),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Memuat cuaca...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : errorMessage != null
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : currentWeather != null
                                    ? Column(
                                        children: [
                                          // Weather Icon - Dynamic based on current weather
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  _getWeatherIconColor(
                                                    currentWeather!['main'],
                                                  ).withOpacity(0.8),
                                                  _getWeatherIconColor(
                                                    currentWeather!['main'],
                                                  ),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getWeatherIconColor(
                                                    currentWeather!['main'],
                                                  ).withOpacity(0.4),
                                                  blurRadius: 15,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _getWeatherIcon(
                                                  currentWeather!['main']),
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),

                                          SizedBox(height: 16),

                                          // Temperature - Lebih besar sesuai gambar
                                          Text(
                                            '${currentWeather!['temperature'].round()}°',
                                            style: TextStyle(
                                              fontSize: 72,
                                              fontWeight: FontWeight.w200,
                                              color: Colors.white,
                                              height: 1.0,
                                            ),
                                          ),

                                          SizedBox(height: 8),

                                          // Weather Condition
                                          Text(
                                            _capitalizeFirst(
                                              currentWeather!['description'],
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),

                                          SizedBox(height: 4),

                                          // Range Temperature seperti di gambar
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Tertinggi: ${(currentWeather!['temperature'] + 3).round()}° • Terendah: ${(currentWeather!['temperature'] - 5).round()}°',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                      ),

                      SizedBox(height: 16),

                      // Weather Details - Lebar maksimal
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            if (currentWeather != null) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildWeatherDetailCard(
                                      icon: Icons.water_drop,
                                      label: 'Kelembaban',
                                      value: '${currentWeather!['humidity']}%',
                                      iconColor: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildWeatherDetailCard(
                                      icon: Icons.air,
                                      label: 'Angin',
                                      value:
                                          '${(currentWeather!['windSpeed'] * 3.6).round()} km/j',
                                      iconColor: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildWeatherDetailCard(
                                      icon: Icons.remove_red_eye,
                                      label: 'Jarak Pandang',
                                      value:
                                          '${((currentWeather!['visibility'] ?? 10000) / 1000).round()} km',
                                      iconColor: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildWeatherDetailCard(
                                      icon: Icons.compress,
                                      label: 'Tekanan',
                                      value:
                                          '${(currentWeather!['pressure'] ?? 1013).round()} hPa',
                                      iconColor: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Forecast Section - Lebar maksimal
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Prakiraan Cuaca',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Per Jam',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Hourly Forecast - Always show
                            if (hourlyForecast.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Prakiraan 24 Jam Ke Depan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    // Horizontal scrollable hourly forecast
                                    Container(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            hourlyForecast.take(24).length,
                                        itemBuilder: (context, index) {
                                          final forecast =
                                              hourlyForecast[index];
                                          final isNow = index == 0;
                                          return Container(
                                            width: 80,
                                            margin: EdgeInsets.only(
                                              right: index <
                                                      hourlyForecast.length - 1
                                                  ? 12
                                                  : 0,
                                            ),
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: isNow
                                                  ? LinearGradient(
                                                      colors: [
                                                        Color(0xFF4CAF50),
                                                        Color(0xFF66BB6A),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    )
                                                  : null,
                                              color: isNow
                                                  ? null
                                                  : Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: isNow
                                                  ? Border.all(
                                                      color: Colors.green,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Waktu
                                                Text(
                                                  isNow
                                                      ? 'Sekarang'
                                                      : _formatTime(
                                                          forecast['datetime'],
                                                        ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isNow
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Icon cuaca
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: isNow
                                                        ? Colors.white
                                                            .withOpacity(0.2)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    _getWeatherIcon(
                                                      forecast['icon'],
                                                    ),
                                                    size: 20,
                                                    color: isNow
                                                        ? Colors.white
                                                        : Colors.orange,
                                                  ),
                                                ),
                                                // Suhu
                                                Text(
                                                  '${forecast['temperature'].round()}°',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: isNow
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                // Kelembaban
                                                Text(
                                                  '${forecast['humidity']}%',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isNow
                                                        ? Colors.white
                                                            .withOpacity(0.8)
                                                        : Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Scroll indicator
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.swipe_left,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Geser untuk melihat lebih banyak',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Weekly Forecast
                            if (weeklyForecast.isNotEmpty) ...[
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Prakiraan 7 Hari Ke Depan',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ...weeklyForecast.map((dayForecast) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Day
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                dayForecast['day'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            // Weather Icon
                                            Icon(
                                              _getWeatherIcon(
                                                dayForecast['main'],
                                              ),
                                              color: _getWeatherIconColor(
                                                dayForecast['main'],
                                              ),
                                              size: 24,
                                            ),
                                            SizedBox(width: 16),
                                            // Description
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                dayForecast['description'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Temperature
                                            Flexible(
                                              child: Text(
                                                '${dayForecast['temp_max']}°/${dayForecast['temp_min']}°',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
