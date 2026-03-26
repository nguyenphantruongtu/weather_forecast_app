import 'package:flutter/material.dart';

/// Maps weather condition strings to emojis and icons
/// Supports both OpenWeather API formats and custom descriptions
class WeatherIconMapper {
  // Private constructor to prevent instantiation
  WeatherIconMapper._();

  // ============================================================
  // EMOJI MAPPING
  // ============================================================

  /// Get emoji from OpenWeather 'main' condition (e.g., "Clear", "Rain")
  /// Aligned with WeatherDay model
  static String emojiForMain(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '🌨️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '☀️';
    }
  }

  /// Get emoji from weather description (more detailed)
  /// Supports various formats: "clear", "sunny", "partly cloudy", etc.
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

  // ============================================================
  // FLUTTER ICON MAPPING
  // ============================================================

  /// Get Flutter IconData from weather description
  /// Useful for Material Design icons
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

  // ============================================================
  // TEXT FORMATTING
  // ============================================================

  /// Get display text for weather condition
  /// Capitalizes and formats the condition properly
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
        // Capitalize first letter
        if (description.isEmpty) return description;
        return description[0].toUpperCase() + description.substring(1);
    }
  }

  // ============================================================
  // COLOR MAPPING
  // ============================================================

  /// Get color based on weather condition
  /// Useful for UI theming
  static Color getConditionColor(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return const Color(0xFFFF9500); // Orange
      case 'clouds':
      case 'cloudy':
        return const Color(0xFF8E8E93); // Gray
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return const Color(0xFF007AFF); // Blue
      case 'thunderstorm':
      case 'storm':
        return const Color(0xFF5856D6); // Purple
      case 'snow':
      case 'snowy':
        return const Color(0xFF5AC8FA); // Light Blue
      case 'mist':
      case 'fog':
        return const Color(0xFFAEAEB2); // Light Gray
      default:
        return const Color(0xFF007AFF); // Default Blue
    }
  }

  // ============================================================
  // ICON CODE MAPPING (OpenWeatherMap)
  // ============================================================

  /// Get emoji from OpenWeather icon code (e.g., "01d", "10n")
  static String emojiFromIconCode(String iconCode) {
    // Remove day/night indicator
    final code = iconCode.replaceAll(RegExp(r'[dn]$'), '');
    
    switch (code) {
      case '01': // clear sky
        return '☀️';
      case '02': // few clouds
        return '⛅';
      case '03': // scattered clouds
      case '04': // broken clouds
        return '☁️';
      case '09': // shower rain
      case '10': // rain
        return '🌧️';
      case '11': // thunderstorm
        return '⛈️';
      case '13': // snow
        return '🌨️';
      case '50': // mist
        return '🌫️';
      default:
        return '☀️';
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Check if condition is rainy
  static bool isRainy(String description) {
    final lower = description.toLowerCase();
    return lower.contains('rain') || 
           lower.contains('drizzle') || 
           lower.contains('storm');
  }

  /// Check if condition is clear/sunny
  static bool isClear(String description) {
    final lower = description.toLowerCase();
    return lower.contains('clear') || lower.contains('sunny');
  }

  /// Check if condition is cloudy
  static bool isCloudy(String description) {
    final lower = description.toLowerCase();
    return lower.contains('cloud');
  }

  /// Check if condition is snowy
  static bool isSnowy(String description) {
    final lower = description.toLowerCase();
    return lower.contains('snow');
  }
}