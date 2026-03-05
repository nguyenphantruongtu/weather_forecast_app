import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'data/services/open_meteo_service.dart';
import 'data/services/weather_api_service.dart';
import 'screens/sv5_screens/calendar_screen/calendar_screen.dart';
import 'screens/sv5_screens/calendar_screen/providers/calendar_provider.dart';
import 'screens/sv5_screens/statistics_screen/statistics_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const WeatherNowApp());
}

class WeatherNowApp extends StatelessWidget {
  const WeatherNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WeatherNow',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F1B2B),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FACFE)),
        ),
        routes: {
          '/calendar': (_) => const CalendarScreen(),
          '/statistics': (_) => const StatisticsScreen(),
        },
        home: const CalendarScreen(),
      ),
    );
  }
}
