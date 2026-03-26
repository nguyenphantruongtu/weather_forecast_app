import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:final_project/data/models/weather_day_model.dart';
import 'package:final_project/data/services/weather_api_service.dart';
import 'package:final_project/providers/calendar_provider.dart';
import 'package:final_project/providers/statistics_provider.dart';
import 'package:final_project/providers/widget_config_provider.dart';
import 'package:final_project/screens/weather_home_shell.dart';

class _StubWeatherApi extends WeatherApiService {
  _StubWeatherApi()
    : super(
        dio: Dio(),
        apiKey: 'test',
        baseUrl: 'https://api.openweathermap.org/data/2.5',
      );

  @override
  Future<Map<DateTime, WeatherDay>> fetchAppWeatherDays({
    required double lat,
    required double lon,
  }) async {
    final n = DateTime.now();
    final k = DateTime(n.year, n.month, n.day);
    return {
      k: WeatherDay(
        date: k,
        tempMax: 28,
        tempMin: 22,
        condition: 'Clear',
        icon: '☀️',
        description: 'clear sky',
        humidity: 50,
        windSpeed: 0,
        precipitation: 0,
        uvIndex: 0,
        sunrise: DateTime(k.year, k.month, k.day, 6),
        sunset: DateTime(k.year, k.month, k.day, 18),
      ),
    };
  }
}

void main() {
  testWidgets('Calendar tab shows title with stub weather API', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<WeatherApiService>(create: (_) => _StubWeatherApi()),
          ChangeNotifierProvider(
            create: (c) =>
                CalendarProvider(apiService: c.read<WeatherApiService>()),
          ),
          ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
            create: (c) => StatisticsProvider(
              calendarProvider: c.read<CalendarProvider>(),
            ),
            update: (_, cal, prev) =>
                prev ?? StatisticsProvider(calendarProvider: cal),
          ),
          ChangeNotifierProvider(create: (_) => WidgetConfigProvider()),
        ],
        child: const MaterialApp(
          home: WeatherHomeShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Weather Calendar'), findsOneWidget);
  });
}
