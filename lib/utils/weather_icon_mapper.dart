import 'package:flutter/material.dart';

class WeatherIconMapper {
  static String getWeatherEmoji(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return '☀️';
      case 'clouds':
      case 'cloudy':
        return '☁️';
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
      case 'storm':
        return '⛈️';
      case 'snow':
      case 'snowy':
        return '❄️';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
      case 'windy':
        return '🌫️';
      case 'partly cloudy':
        return '⛅';
      default:
        return '🌤️';
    }
  }

  static IconData getWeatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return Icons.sunny;
      case 'clouds':
      case 'cloudy':
        return Icons.wb_cloudy;
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
      case 'storm':
        return Icons.flash_on;
      case 'snow':
      case 'snowy':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  static String getConditionText(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return 'Clear';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rainy';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Thunderstorm';
      case 'snow':
        return 'Snowy';
      case 'mist':
      case 'fog':
        return 'Foggy';
      default:
        return description;
    }
  }
}
