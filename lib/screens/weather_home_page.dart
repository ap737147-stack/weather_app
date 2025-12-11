import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../utils/weather_utils.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherData? _weatherData;
  List<HourlyForecast> _hourlyForecast = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<LocationSuggestion> _suggestions = [];
  bool _isDarkMode = true;
  bool _showTodayForecast = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _weatherService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weatherData = weather;
        _hourlyForecast = _weatherService.getHourlyForecast(
          weather.temperature,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchWeather(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestions.clear();
    });

    try {
      final weather = await _weatherService.fetchWeatherByCity(query);
      setState(() {
        _weatherData = weather;
        _hourlyForecast = _weatherService.getHourlyForecast(
          weather.temperature,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions.clear());
      return;
    }

    try {
      final suggestions = await _weatherService.searchLocations(query);
      setState(() => _suggestions = suggestions);
    } catch (e) {
      setState(() => _suggestions.clear());
    }
  }

  Future<void> _selectLocation(LocationSuggestion suggestion) async {
    _searchController.text = suggestion.name;
    setState(() {
      _suggestions.clear();
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeatherByCoordinates(
        suggestion.lat,
        suggestion.lon,
      );
      setState(() {
        _weatherData = weather;
        _hourlyForecast = _weatherService.getHourlyForecast(
          weather.temperature,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _errorMessage != null
                  ? _buildErrorMessage()
                  : _weatherData != null
                  ? _buildWeatherContent()
                  : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search City',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _searchLocations,
                onSubmitted: _searchWeather,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isDarkMode = !_isDarkMode),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (_suggestions.isNotEmpty) _buildSuggestions(),
          _buildMainWeather(),
          const SizedBox(height: 24),
          _buildWeatherStats(),
          const SizedBox(height: 24),
          _buildForecastTabs(),
          const SizedBox(height: 16),
          _showTodayForecast ? _buildTodayForecast() : _buildWeeklyForecast(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade800, height: 1),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.orange),
            title: Text(
              suggestion.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${suggestion.state ?? ''} ${suggestion.country}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            onTap: () => _selectLocation(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildMainWeather() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '${_weatherData!.cityName}, ${_weatherData!.country}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_weatherData!.temperature.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            _weatherData!.description,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
          const SizedBox(height: 32),
          Icon(
            WeatherUtils.getWeatherIconData(_weatherData!.icon),
            size: 120,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.water_drop,
            '${_weatherData!.humidity}%',
            'Humidity',
          ),
          _buildStatItem(
            Icons.air,
            '${_weatherData!.windSpeed.toStringAsFixed(1)} kph',
            'Wind',
          ),
          _buildStatItem(
            Icons.thermostat,
            '${_weatherData!.tempMax.round()}°',
            'Max Temp',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade300, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildForecastTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTodayForecast = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _showTodayForecast
                          ? Colors.orange
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Today Forecast',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showTodayForecast
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTodayForecast = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: !_showTodayForecast
                          ? Colors.orange
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Weekly Forecast',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showTodayForecast
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayForecast() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = _hourlyForecast[index];
          final isFirst = index == 0;
          return Container(
            width: 80,
            margin: EdgeInsets.only(
              right: index < _hourlyForecast.length - 1 ? 12 : 0,
            ),
            decoration: BoxDecoration(
              gradient: isFirst
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFF9800), Color(0xFFFF6B00)],
                    )
                  : null,
              color: isFirst ? null : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  forecast.time,
                  style: TextStyle(
                    color: isFirst ? Colors.white : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  Icons.wb_sunny,
                  color: isFirst ? Colors.white : Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  '${forecast.temperature.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(7, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    days[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
                const Spacer(),
                Text(
                  '${(_weatherData!.tempMax - index).round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_weatherData!.tempMin - index).round()}°',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.orange));
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getCurrentLocationWeather,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            'Search for a city to get started',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
