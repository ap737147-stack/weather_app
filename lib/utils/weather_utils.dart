import 'package:flutter/material.dart';

class WeatherUtils {
  static IconData getWeatherIconData(String iconCode) {
    final code = iconCode.substring(0, 2);
    switch (code) {
      case '01':
        return Icons.wb_sunny;
      case '02':
        return Icons.wb_cloudy;
      case '03':
        return Icons.cloud;
      case '04':
        return Icons.cloud;
      case '09':
        return Icons.grain;
      case '10':
        return Icons.beach_access;
      case '11':
        return Icons.flash_on;
      case '13':
        return Icons.ac_unit;
      case '50':
        return Icons.blur_on;
      default:
        return Icons.wb_sunny;
    }
  }
}
