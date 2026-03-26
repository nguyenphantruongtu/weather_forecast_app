import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/env_config.dart';
import 'data/services/weather_api_service.dart';
import 'providers/calendar_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/widget_config_provider.dart';
import 'screens/weather_home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: EnvConfig.envFileName);

  if (!EnvConfig.isConfigValid) {
    // ignore: avoid_print
    print('Missing API keys:');
    for (final key in EnvConfig.validateApiKeys()) {
      // ignore: avoid_print
      print('   - $key');
    }
  }

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherApiService>(
          create: (_) => WeatherApiService(
            dio: Dio(),
            apiKey: EnvConfig.openWeatherApiKey,
            baseUrl: EnvConfig.openWeatherBaseUrl,
          ),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            apiService: context.read<WeatherApiService>(),
          ),
        ),
        ChangeNotifierProxyProvider<CalendarProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(
            calendarProvider: context.read<CalendarProvider>(),
          ),
          update: (_, calendar, previous) =>
              previous ?? StatisticsProvider(calendarProvider: calendar),
        ),
        ChangeNotifierProvider<WidgetConfigProvider>(
          create: (_) => WidgetConfigProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const WeatherHomeShell(),
        routes: {
          '/calendar': (_) => const WeatherHomeShell(),
          '/statistics': (_) => const WeatherHomeShell(),
          '/widgets': (_) => const WeatherHomeShell(),
        },
      ),
    );
  }
}
