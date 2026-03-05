import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'data/services/open_meteo_service.dart';
import 'data/services/weather_api_service.dart';
import 'screens/sv5_screens/calendar_screen/providers/calendar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fileName: '.env' — explicit hơn, rõ ràng hơn cách viết không có tham số
  await dotenv.load(fileName: '.env');

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // --- Providers từ HEAD ---
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => NewsProvider()),

        // --- Providers từ TuNPT (sv5) ---
        Provider<WeatherApiService>(
          create: (_) => WeatherApiService(
            dio: Dio(),
            apiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
            baseUrl:
                dotenv.env['OPENWEATHER_BASE_URL'] ??
                'https://api.openweathermap.org/data/2.5',
          ),
        ),
        Provider<OpenMeteoService>(
          create: (_) => OpenMeteoService(dio: Dio()),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            weatherApiService: context.read<WeatherApiService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}