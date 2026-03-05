import 'package:flutter/material.dart';

import '../models/weather_day_model.dart';

class TemperatureGradient {
  const TemperatureGradient._();

  static Gradient fromTemp(double temp) {
    if (temp >= 30) {
      return WeatherUiPalette.hotGradient;
    }
    if (temp <= 15) {
      return WeatherUiPalette.coldGradient;
    }
    return WeatherUiPalette.normalGradient;
  }

  static Color uvColor(double uv) {
    if (uv < 3) return const Color(0xFF00FF66);
    if (uv < 6) return const Color(0xFFFFFF00);
    if (uv < 8) return const Color(0xFFFF9800);
    if (uv < 11) return const Color(0xFFFF3D00);
    return const Color(0xFF9C27B0);
  }
}
