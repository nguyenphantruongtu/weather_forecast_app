import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'screens/sv2_screens/home_screen/home_screen.dart';
import 'screens/sv2_screens/hourly_forecast_screen/hourly_forecast_screen.dart';
import 'screens/sv2_screens/daily_forecast_screen/daily_forecast_screen.dart';
import 'screens/sv2_screens/weather_details_screen/weather_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
      child: MaterialApp(
        title: 'Weather Now App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/hourly-forecast': (_) => const HourlyForecastScreen(),
          '/daily-forecast': (_) => const DailyForecastScreen(),
          '/weather-details': (_) => const WeatherDetailsScreen(),
        },
      ),
    );
  }
}
