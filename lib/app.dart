import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/OnboardingAndUserPreferencesScreens/splash_screen/splash_screen.dart';
import 'screens/OnboardingAndUserPreferencesScreens/onboarding_screen/onboarding_screen.dart';
import 'screens/OnboardingAndUserPreferencesScreens/location_setup_screen/location_setup_screen.dart';
import 'screens/OnboardingAndUserPreferencesScreens/settings_screen/settings_screen.dart';
import 'screens/OnboardingAndUserPreferencesScreens/info_screen/info_screen.dart';
import 'screens/sv2_screens/home_screen/home_screen.dart';
import 'screens/sv2_screens/hourly_forecast_screen/hourly_forecast_screen.dart';

/// Root widget của ứng dụng
/// Cung cấp theme và navigation routing cho app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch: theo dõi SettingsProvider, rebuild khi thay đổi
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      // Sử dụng theme dựa trên settings
      theme: ThemeProvider.getTheme(settingsProvider.settings.theme),
      // home: màn hình đầu tiên khi app mở
      home: const SplashScreen(),
      // routes: định tuyến các màn hình
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/location_setup': (_) => const LocationSetupScreen(),
        '/home': (_) => const HomeScreen(),
        '/hourly_forecast': (_) => const HourlyForecastScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/info': (_) => const InfoScreen(),
      },
    );
  }
}