import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_data.dart';

class WeatherService {
  static const String _apiKey = 'c33c35dfe4fa7583a2c428f077008038';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';

  Future<WeatherData> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw WeatherException('City not found');
    }
  }

  Future<WeatherData> fetchWeatherByCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw WeatherException('Failed to fetch weather data');
    }
  }

  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.length < 2) return [];

    final url = Uri.parse('$_geoUrl/direct?q=$query&limit=5&appid=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => LocationSuggestion.fromJson(item)).toList();
    }
    return [];
  }

  List<HourlyForecast> getHourlyForecast(double currentTemp) {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final hour = now.add(Duration(hours: index));
      final temp = currentTemp + (index * 0.5) - 1;
      return HourlyForecast(
        time: index == 0
            ? 'Now'
            : '${hour.hour % 12 == 0 ? 12 : hour.hour % 12} ${hour.hour >= 12 ? 'PM' : 'AM'}',
        temperature: temp,
        icon: '01d',
      );
    });
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
