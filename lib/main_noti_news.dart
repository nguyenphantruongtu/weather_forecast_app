import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/NotiAndNewsScreens/noti_news_main_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/news_provider.dart';
import 'providers/notification_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  tz.initializeTimeZones();
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const NotiNewsApp(),
    ),
  );
}

class NotiNewsApp extends StatelessWidget {
  const NotiNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotiNewsMainScreen(),
    );
  }
}