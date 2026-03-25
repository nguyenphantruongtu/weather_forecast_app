import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';

// --- Imports từ develop ---
import 'data/services/open_meteo_service.dart';
import 'data/services/weather_api_service.dart';
import 'screens/sv5_screens/calendar_screen/providers/calendar_provider.dart';

// --- Imports từ TungNQ ---
import 'providers/weather_provider.dart';
import 'providers/location_provider.dart';
import 'providers/saved_locations_provider.dart';
import 'features/location_search_screen/location_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load file .env
  await dotenv.load(fileName: '.env');

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // 1. Cấu hình chung
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => NewsProvider()),

        // 2. Services (Lấy key từ file .env truyền vào API Service)
        Provider<WeatherApiService>(
          create: (_) => WeatherApiService(
            dio: Dio(),
            apiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
            baseUrl: dotenv.env['OPENWEATHER_BASE_URL'] ?? 'https://api.openweathermap.org/data/2.5',
          ),
        ),
        Provider<OpenMeteoService>(
          create: (_) => OpenMeteoService(dio: Dio()),
        ),

        // 3. ViewModels / Providers logic
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            weatherApiService: context.read<WeatherApiService>(),
          ),
        ),
        
        // --- Providers giữ lại từ branch của Tùng ---
        ChangeNotifierProvider(create: (_) => WeatherProvider()), 
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SavedLocationsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App Group 6',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LocationSearchScreen(), 
    );
  }
}