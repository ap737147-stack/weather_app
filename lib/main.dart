import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Search App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final String apiKey = 'c33c35dfe4fa7583a2c428f077008038';

  WeatherData? weatherData;
  bool isLoading = false;
  String? errorMessage;
  List<LocationSuggestion> suggestions = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocationWeather();
  }

  Future<void> getCurrentLocationWeather() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage =
              'Location services are disabled. Please enable location services.';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage =
                'Location permissions are denied. Please grant location access.';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              'Location permissions are permanently denied. Please enable in settings.';
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await getWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get current location: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> searchWeather(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      suggestions.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$query&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(data);
          isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          errorMessage = errorData['message'] ?? 'Location not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Failed to fetch weather data. Please check your internet connection.';
        isLoading = false;
      });
    }
  }

  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch weather data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch weather data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> searchLocations(String query) async {
    if (query.length < 3) {
      setState(() {
        suggestions.clear();
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          suggestions = data
              .map((item) => LocationSuggestion.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  String getWeatherIcon(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01':
        return '☀️';
      case '02':
        return '⛅';
      case '03':
        return '☁️';
      case '04':
        return '☁️';
      case '09':
        return '🌧️';
      case '10':
        return '🌦️';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  Color _getGradientColor() {
    if (weatherData == null) return Colors.blue.shade400;

    final icon = weatherData!.icon.substring(0, 2);
    switch (icon) {
      case '01':
        return Colors.orange.shade300;
      case '02':
      case '03':
      case '04':
        return Colors.blue.shade300;
      case '09':
      case '10':
        return Colors.indigo.shade400;
      case '11':
        return Colors.deepPurple.shade400;
      case '13':
        return Colors.cyan.shade300;
      case '50':
        return Colors.blueGrey.shade300;
      default:
        return Colors.blue.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradientColor(),
              _getGradientColor().withOpacity(0.7),
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Search
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  children: [
                    Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search city...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.blue.shade600,
                            size: 24,
                          ),
                          suffixIcon: Container(
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: getCurrentLocationWeather,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: searchLocations,
                        onSubmitted: searchWeather,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Location Suggestions
                        if (suggestions.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            constraints: BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              itemCount: suggestions.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1, indent: 60),
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    suggestion.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${suggestion.country}${suggestion.state != null ? ', ${suggestion.state}' : ''}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onTap: () {
                                    _searchController.text = suggestion.name;
                                    getWeatherByCoordinates(
                                      suggestion.lat,
                                      suggestion.lon,
                                    );
                                    setState(() {
                                      suggestions.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 20),

                        // Loading Indicator
                        if (isLoading)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Fetching weather data...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Error Message
                        if (errorMessage != null && !isLoading)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Weather Card
                        if (weatherData != null && !isLoading)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 25,
                                  offset: Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Location
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        '${weatherData!.cityName}, ${weatherData!.country}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade800,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25),

                                // Weather Icon & Temperature
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    getWeatherIcon(weatherData!.icon),
                                    style: TextStyle(fontSize: 80),
                                  ),
                                ),
                                SizedBox(height: 20),

                                Text(
                                  '${weatherData!.temperature.round()}°',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.blue.shade700,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: 10),

                                Text(
                                  weatherData!.description.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 30),

                                // Weather Details Grid
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildWeatherDetail(
                                            Icons.thermostat_outlined,
                                            'Feels Like',
                                            '${weatherData!.feelsLike.round()}°C',
                                          ),
                                          _buildWeatherDetail(
                                            Icons.water_drop_outlined,
                                            'Humidity',
                                            '${weatherData!.humidity}%',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildWeatherDetail(
                                            Icons.air,
                                            'Wind Speed',
                                            '${weatherData!.windSpeed.round()} m/s',
                                          ),
                                          _buildWeatherDetail(
                                            Icons.compress,
                                            'Pressure',
                                            '${weatherData!.pressure} hPa',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      _buildWeatherDetail(
                                        Icons.visibility_outlined,
                                        'Visibility',
                                        '${(weatherData!.visibility / 1000).round()} km',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Default message
                        if (weatherData == null &&
                            !isLoading &&
                            errorMessage == null)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wb_sunny_outlined,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                SizedBox(height: 30),
                                Text(
                                  'Discover the Weather',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Search for any city or use your\ncurrent location to get started',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 28),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final int visibility;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.visibility,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      visibility: json['visibility'] ?? 0,
    );
  }
}

class LocationSuggestion {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'],
      country: json['country'],
      state: json['state'],
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
    );
  }
}
