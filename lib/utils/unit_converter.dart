import 'package:flutter/material.dart';

class UnitConverter {
  // Temperature conversions
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static double celsiusToKelvin(double celsius) {
    return celsius + 273.15;
  }

  static double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  // Wind speed conversions
  static double msToKmh(double ms) {
    return ms * 3.6;
  }

  static double kmhToMs(double kmh) {
    return kmh / 3.6;
  }

  static double msToMph(double ms) {
    return ms * 2.237;
  }

  static double mphToMs(double mph) {
    return mph / 2.237;
  }

  // Pressure conversions
  static double paToMb(double pa) {
    return pa / 100;
  }

  static double paToAtm(double pa) {
    return pa / 101325;
  }

  // Visibility
  static double metersToKm(double meters) {
    return meters / 1000;
  }

  // UV Index strength
  static String getUVIndexStrength(double uvIndex) {
    if (uvIndex < 3) return 'Low';
    if (uvIndex < 6) return 'Moderate';
    if (uvIndex < 8) return 'High';
    if (uvIndex < 11) return 'Very High';
    return 'Extreme';
  }

  // UV Index color
  static Color getUVIndexColor(double uvIndex) {
    if (uvIndex < 3) return Colors.green;
    if (uvIndex < 6) return Colors.yellow;
    if (uvIndex < 8) return Colors.orange;
    if (uvIndex < 11) return Colors.red;
    return Colors.purple;
  }
}
