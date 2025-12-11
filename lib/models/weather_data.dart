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
  final double tempMin;
  final double tempMax;

  const WeatherData({
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
    required this.tempMin,
    required this.tempMax,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? '',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      pressure: json['main']?['pressure'] ?? 0,
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      visibility: json['visibility'] ?? 0,
      tempMin: (json['main']?['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']?['temp_max'] ?? 0).toDouble(),
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final String icon;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
  });
}

class LocationSuggestion {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  const LocationSuggestion({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
    );
  }
}
