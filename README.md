# 🌤️ Weather Forecast App

A beautiful, modern weather application built with Flutter featuring a sleek dark theme, real-time weather data, and hourly/weekly forecasts.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- 🌍 **Current Location Weather** - Automatically fetch weather for your location
- 🔍 **City Search** - Search for any city worldwide with auto-suggestions
- 📊 **Hourly Forecast** - View weather predictions for the next 6 hours
- 📅 **Weekly Forecast** - 7-day weather forecast with high/low temperatures
- 🎨 **Beautiful Dark UI** - Modern dark theme with smooth animations
- 🌓 **Theme Toggle** - Switch between dark and light modes
- 📱 **Responsive Design** - Optimized for all screen sizes
- ⚡ **Real-time Data** - Live weather updates from OpenWeatherMap API

## 📸 Screenshots

```
┌─────────────────────────────┐
│   🔍 Search City       🌙   │
├─────────────────────────────┤
│                             │
│      Delhi, India           │
│        31.2°C               │
│         Mist                │
│                             │
│          ☁️                 │
│                             │
│  💧63%   🌬️8.6kph  🌡️36.1  │
│                             │
│ Today Forecast | Weekly     │
├─────────────────────────────┤
│ [Now] [2PM] [3PM] [4PM]...  │
└─────────────────────────────┘
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- OpenWeatherMap API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Github-ap737147-stack/weather-app.git
   cd weather-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your API Key**
   
   Open `main.dart` and replace the API key:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```
   
   Get your free API key from [OpenWeatherMap](https://openweathermap.org/api)

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0          # For API calls
  geolocator: ^10.1.0   # For location services
```

## ⚙️ Configuration

### Android Setup

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show weather data</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show weather data</string>
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── models/
│   ├── weather_data.dart     # Weather data model
│   ├── hourly_forecast.dart  # Hourly forecast model
│   └── location_suggestion.dart
├── services/
│   ├── weather_service.dart  # API service
│   └── location_service.dart # Location service
├── screens/
│   └── weather_home_page.dart
└── utils/
    └── weather_utils.dart    # Helper functions
```

## 🎨 Features Breakdown

### 🌡️ Current Weather
- Real-time temperature
- Weather description
- City and country name
- Weather icon

### 📊 Weather Details
- Humidity percentage
- Wind speed
- Maximum temperature
- Feels like temperature
- Pressure
- Visibility

### ⏰ Hourly Forecast
- Next 6 hours prediction
- Temperature for each hour
- Weather icons
- Highlighted current hour

### 📅 Weekly Forecast
- 7-day prediction
- High and low temperatures
- Weather conditions
- Day of the week

## 🔧 Customization

### Change Theme Colors

Edit colors in `main.dart`:

```dart
// Dark theme colors
const Color darkBackground = Color(0xFF1A1A1A);
const Color darkCard = Color(0xFF2A2A2A);
const Color accentOrange = Color(0xFFFF9800);

// Gradient colors
const orangeGradient = LinearGradient(
  colors: [Color(0xFFFF9800), Color(0xFFFF6B00)],
);
```

### Modify API Configuration

```dart
class WeatherService {
  static const String _apiKey = 'YOUR_KEY';
  static const String _units = 'metric'; // or 'imperial'
}
```

## 🐛 Troubleshooting

### Location Not Working

1. Check permissions are granted
2. Enable location services on device
3. Test on a real device (emulator may have issues)

### API Errors

1. Verify your API key is valid
2. Check internet connection
3. Ensure city name is correct

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Supported Platforms

- ✅ Android (6.0+)
- ✅ iOS (12.0+)
- ✅ Web (experimental)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Github-ap737147-stack**
- GitHub: [@ap737147-stack](https://github.com/ap737147-stack)
- Email: ap737147@gmail.com

## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) - Weather API
- [Flutter](https://flutter.dev/) - UI Framework
- [Material Icons](https://fonts.google.com/icons) - Icons

## 📞 Support

If you have any questions or need help, please:
- Open an issue on [GitHub](https://github.com/Github-ap737147-stack/weather_app/issues)
- Email: ap737147@gmail.com

## 🗺️ Roadmap

- [ ] Add weather maps
- [ ] Multiple location support
- [ ] Weather alerts and notifications
- [ ] Historical weather data
- [ ] Widget support
- [ ] Offline mode with cached data
- [ ] Custom themes
- [ ] Share weather updates

## 💡 Tips

- **Better Accuracy**: Allow location permissions for automatic weather updates
- **Save Searches**: Favorite cities for quick access
- **Stay Updated**: Enable notifications for weather alerts
- **Battery Saving**: Disable auto-location in settings

---

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it weather-appapp
