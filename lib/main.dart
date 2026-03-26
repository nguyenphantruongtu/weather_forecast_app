import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

// App
import 'app.dart';

// Config
import 'config/env_config.dart';

// Services
import 'data/services/weather_api_service.dart';
import 'data/services/notification_service.dart';

// Providers - Original (HEAD)
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/location_provider.dart';

// Providers - New (TuNPT - SV5)
import 'providers/calendar_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/widget_config_provider.dart';

// Screens
import 'screens/weather_home_shell.dart';

/// Entry point của ứng dụng
void main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables từ file .env
    await dotenv.load(fileName: EnvConfig.envFileName);

    // Validate API keys
    if (!EnvConfig.isConfigValid) {
      debugPrint('⚠️ Missing API keys:');
      for (final key in EnvConfig.validateApiKeys()) {
        debugPrint('   - $key');
      }
    }

    // Khởi tạo dữ liệu locale cho DateFormat (vi_VN, en_US, etc.)
    await initializeDateFormatting();

    // Khởi tạo timezone data cho notification
    tz.initializeTimeZones();
    await NotificationService().initialize();

    // Khởi tạo SettingsProvider và load settings từ SharedPreferences
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();

    // Chạy ứng dụng
    runApp(
      MultiProvider(
        providers: [
          // ============================================================
          // ORIGINAL PROVIDERS (HEAD - Team khác)
          // ============================================================
          
          // Settings Provider
          ChangeNotifierProvider.value(value: settingsProvider),

          // News Provider
          ChangeNotifierProvider(create: (_) => NewsProvider()),

          // Weather Provider (Home screen)
          ChangeNotifierProvider(create: (_) => WeatherProvider()),

          // Notification Provider
          ChangeNotifierProvider(create: (_) => NotificationProvider()),

          // Location Provider
          ChangeNotifierProvider(create: (_) => LocationProvider()),

          // ============================================================
          // NEW PROVIDERS (TuNPT - SV5 Screens)
          // ============================================================

          // Weather API Service (singleton)
          Provider<WeatherApiService>(
            create: (_) => WeatherApiService(
              dio: Dio(),
              apiKey: EnvConfig.openWeatherApiKey,
              baseUrl: EnvConfig.openWeatherBaseUrl,
            ),
          ),

          // Widget Config Provider (for theme)
          ChangeNotifierProvider<WidgetConfigProvider>(
            create: (_) => WidgetConfigProvider(),
          ),

          // Calendar Provider
          ChangeNotifierProvider<CalendarProvider>(
            create: (ctx) => CalendarProvider(
              apiService: ctx.read<WeatherApiService>(),
            ),
          ),

          // Statistics Provider (depends on CalendarProvider)
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
  } catch (e, stackTrace) {
    // Nếu có lỗi khởi tạo, hiển thị error screen
    debugPrint('❌ Initialization Error: $e');
    debugPrint('Stack trace: $stackTrace');
    
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stackTrace.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Restart app
                      runApp(const MaterialApp(home: SizedBox.shrink()));
                      main();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}