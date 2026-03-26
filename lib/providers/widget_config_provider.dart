import 'package:flutter/material.dart';

import '../data/models/widget_config_model.dart';

class WidgetConfigProvider extends ChangeNotifier {
  AppWidgetTheme _selectedTheme = const AppWidgetTheme(
    name: 'Classic',
    color: Color(0xFF007AFF),
  );

  final List<AppWidgetTheme> themes = const [
    AppWidgetTheme(name: 'Classic', color: Color(0xFF007AFF)),
    AppWidgetTheme(
      name: 'Minimal',
      color: Color(0xFFF5F5F5),
      textColor: Color(0xDD000000),
    ),
    AppWidgetTheme(name: 'Colorful', color: Color(0xFFFF2D55)),
    AppWidgetTheme(
      name: 'Dark Mode',
      color: Color(0xFF1C1C1E),
      textColor: Colors.white,
    ),
    AppWidgetTheme(name: 'Gradient', color: Color(0xFF667eea)),
  ];

  final List<AppWidgetSize> widgetSizes = const [
    AppWidgetSize(name: 'Calendar', size: '2x2', isFree: true, isPopular: true),
    AppWidgetSize(
      name: 'Statistics',
      size: '2x2',
      isFree: true,
      isPopular: false,
    ),
    AppWidgetSize(
      name: 'Current Weather',
      size: '4x2',
      isFree: true,
      isPopular: true,
    ),
    AppWidgetSize(
      name: 'Forecast',
      size: '4x2',
      isFree: true,
      isPopular: false,
    ),
  ];

  AppWidgetTheme get selectedTheme => _selectedTheme;

  void selectTheme(AppWidgetTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
