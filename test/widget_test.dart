import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// App
import 'package:final_project/app.dart';

// Models
import 'package:final_project/data/models/weather_day_model.dart';

// Services
import 'package:final_project/data/services/weather_api_service.dart';

// Providers - Original (HEAD)
import 'package:final_project/providers/settings_provider.dart';
import 'package:final_project/providers/news_provider.dart';
import 'package:final_project/providers/weather_provider.dart';
import 'package:final_project/providers/notification_provider.dart';
import 'package:final_project/providers/location_provider.dart';

// Providers - New (TuNPT)
import 'package:final_project/providers/calendar_provider.dart';
import 'package:final_project/providers/statistics_provider.dart';
import 'package:final_project/providers/widget_config_provider.dart';

// Screens
import 'package:final_project/screens/calendar_screen/calendar_screen.dart';

// ============================================================
// STUB API SERVICE (for testing without real API calls)
// ============================================================

class _StubWeatherApi extends WeatherApiService {
  _StubWeatherApi()
      : super(
          dio: Dio(),
          apiKey: 'test_api_key',
          baseUrl: 'https://api.openweathermap.org/data/2.5',
        );

  @override
  Future<Map<DateTime, WeatherDay>> fetchAppWeatherDays({
    required double lat,
    required double lon,
  }) async {
    // Return mock data for testing
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return {
      today: WeatherDay(
        date: today,
        tempMax: 28,
        tempMin: 22,
        condition: 'Clear',
        icon: '☀️',
        description: 'clear sky',
        humidity: 50,
        windSpeed: 5.0,
        precipitation: 0,
        uvIndex: 5,
        sunrise: DateTime(today.year, today.month, today.day, 6, 0),
        sunset: DateTime(today.year, today.month, today.day, 18, 30),
      ),
      today.add(const Duration(days: 1)): WeatherDay(
        date: today.add(const Duration(days: 1)),
        tempMax: 30,
        tempMin: 24,
        condition: 'Clouds',
        icon: '☁️',
        description: 'partly cloudy',
        humidity: 60,
        windSpeed: 8.0,
        precipitation: 0.2,
        uvIndex: 6,
        sunrise: DateTime(today.year, today.month, today.day + 1, 6, 0),
        sunset: DateTime(today.year, today.month, today.day + 1, 18, 30),
      ),
    };
  }
}

// ============================================================
// TESTS - ORIGINAL (HEAD)
// ============================================================

void main() {
  group('App Launch Tests (Original)', () {
    testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      // Build app with providers similar to production bootstrap
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProvider(create: (_) => NewsProvider()),
            ChangeNotifierProvider(create: (_) => WeatherProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LocationProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Allow SplashScreen delayed timer to fire in test environment
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify that the app has rendered (no errors)
      expect(find.byType(MyApp), findsOneWidget);
    });
  });

  // ============================================================
  // TESTS - NEW (TuNPT - Calendar/Statistics/Widgets)
  // ============================================================

  group('Calendar Screen Tests (SV5)', () {
    testWidgets('Calendar screen shows title with stub weather API',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Stub API Service
            Provider<WeatherApiService>(
              create: (_) => _StubWeatherApi(),
            ),
            
            // Calendar Provider
            ChangeNotifierProvider(
              create: (ctx) => CalendarProvider(
                apiService: ctx.read<WeatherApiService>(),
              ),
            ),
            
            // Statistics Provider
            ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
              create: (ctx) => StatisticsProvider(
                calendarProvider: ctx.read<CalendarProvider>(),
              ),
              update: (_, calendar, previous) =>
                  previous ?? StatisticsProvider(calendarProvider: calendar),
            ),
            
            // Widget Config Provider
            ChangeNotifierProvider(
              create: (_) => WidgetConfigProvider(),
            ),
          ],
          child: const MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify Calendar screen title is displayed
      expect(find.text('Weather Calendar'), findsOneWidget);
    });

    testWidgets('Calendar screen displays month summary card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<WeatherApiService>(
              create: (_) => _StubWeatherApi(),
            ),
            ChangeNotifierProvider(
              create: (ctx) => CalendarProvider(
                apiService: ctx.read<WeatherApiService>(),
              ),
            ),
            ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
              create: (ctx) => StatisticsProvider(
                calendarProvider: ctx.read<CalendarProvider>(),
              ),
              update: (_, calendar, previous) =>
                  previous ?? StatisticsProvider(calendarProvider: calendar),
            ),
            ChangeNotifierProvider(
              create: (_) => WidgetConfigProvider(),
            ),
          ],
          child: const MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Month Summary card is present
      expect(find.text('Month Summary'), findsOneWidget);
    });

    testWidgets('Calendar screen shows loading state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<WeatherApiService>(
              create: (_) => _StubWeatherApi(),
            ),
            ChangeNotifierProvider(
              create: (ctx) => CalendarProvider(
                apiService: ctx.read<WeatherApiService>(),
              ),
            ),
            ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
              create: (ctx) => StatisticsProvider(
                calendarProvider: ctx.read<CalendarProvider>(),
              ),
              update: (_, calendar, previous) =>
                  previous ?? StatisticsProvider(calendarProvider: calendar),
            ),
            ChangeNotifierProvider(
              create: (_) => WidgetConfigProvider(),
            ),
          ],
          child: const MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After async operations complete
      await tester.pumpAndSettle();

      // Loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ============================================================
  // INTEGRATION TESTS
  // ============================================================

  group('Full App Integration Tests', () {
    testWidgets('Full app with all providers launches successfully',
        (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Original providers
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProvider(create: (_) => NewsProvider()),
            ChangeNotifierProvider(create: (_) => WeatherProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LocationProvider()),
            
            // New providers (SV5)
            Provider<WeatherApiService>(
              create: (_) => _StubWeatherApi(),
            ),
            ChangeNotifierProvider<WidgetConfigProvider>(
              create: (_) => WidgetConfigProvider(),
            ),
            ChangeNotifierProvider<CalendarProvider>(
              create: (ctx) => CalendarProvider(
                apiService: ctx.read<WeatherApiService>(),
              ),
            ),
            ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
              create: (ctx) => StatisticsProvider(
                calendarProvider: ctx.read<CalendarProvider>(),
              ),
              update: (_, calendar, previous) =>
                  previous ?? StatisticsProvider(calendarProvider: calendar),
            ),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify app launches without errors
      expect(find.byType(MyApp), findsOneWidget);
    });
  });
}